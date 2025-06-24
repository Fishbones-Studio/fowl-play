extends Node3D

# Exported Variables
@export var input_handler: Node
@export var default_focused_item_name: StringName = &"Arenas"

# Navigation State
var current_index: int = 0
var is_keyboard_navigation_active: bool = false
var is_mouse_hovering: bool = false
var focusable_items: Array[Focusable3D] = []
var is_updating_focus: bool = false # Used to prevent focus loops
var last_top_row_index: int = 1 # Default to a central item

var menu_actions: Dictionary[StringName, UIEnums.UI] = {
	&"Arenas": UIEnums.UI.ARENAS,
	&"EquipmentShop": UIEnums.UI.POULTRYMAN_SHOP,
	&"Equipment": UIEnums.UI.CHICKEN_INVENTORY,
	&"Sacrifice": UIEnums.UI.CHICKEN_SACRIFICE,
	&"RebirthShop": UIEnums.UI.REBIRTH_SHOP
}


func _ready() -> void:
	UIManager.remove_ui_by_enum(UIEnums.UI.PLAYER_HUD)
	_initialize_focusable_items()
	_connect_input_signals()
	_set_initial_focus() # Handles initial highlight and focus
	_preload_items()


func _initialize_focusable_items() -> void:
	# Get all focusable items
	focusable_items = _get_focusable_items()

	if focusable_items.is_empty():
		printerr("No focusable items found. Disabling navigation.")
		return

	# Connect signals for each item
	for i in focusable_items.size():
		var item: Focusable3D = focusable_items[i]
		item.focused.connect(_on_item_focused.bind(i))
		item.unfocused.connect(_on_item_unfocused.bind(i))
		item.pressed.connect(_on_item_pressed.bind(i))


func _connect_input_signals() -> void:
	# Connect input handler signals
	if not input_handler:
		return
	input_handler.selection_moved.connect(_on_move_selection)
	input_handler.current_item_selected.connect(_on_select_current_item)
	# connections for the vertical navigation signals
	input_handler.navigate_up_pressed.connect(_on_navigate_up)
	input_handler.navigate_down_pressed.connect(_on_navigate_down)
	input_handler.keyboard_navigation_activated.connect(
		_on_keyboard_navigation_activated
	)
	input_handler.keyboard_navigation_deactivated.connect(
		_on_keyboard_navigation_deactivated
	)


func _set_initial_focus() -> void:
	if focusable_items.is_empty():
		return
	# Find the index of the default item (e.g., "Flyer")
	var default_index: int = _find_item_index_by_name(default_focused_item_name)
	current_index = max(0, default_index) # Fallback to 0 if not found
	# Set the initial top row index if starting there
	var arenas_index: int = _find_item_index_by_name(&"Arenas")
	if current_index != arenas_index:
		last_top_row_index = current_index
	is_keyboard_navigation_active = true # Act as if keyboard nav is active for initial focus
	highlight_current_item() # Highlight and grab focus of the initial item


func _find_item_index_by_name(item_name: StringName) -> int:
	for i in focusable_items.size():
		if focusable_items[i].name == item_name:
			return i
	printerr(item_name + " not found in focusable_items array!")
	return -1


func _get_focusable_items() -> Array[Focusable3D]:
	var items: Dictionary = {}
	var group_nodes: Array[Node] = get_tree().get_nodes_in_group("focusable_items")

	for node in group_nodes:
		if node is Focusable3D and is_ancestor_of(node):
			items[node] = node.index

	# If no items are found via the group, try finding Focusable3D children
	if items.is_empty():
		items = _find_focusable_children()

	var sorted_values: Array[int] = items.values()
	var sorted_items: Array[Focusable3D] = []

	sorted_values.sort_custom(func(a, b): return a > b)

	for index in sorted_values:
		sorted_items.append(items.find_key(index))

	return sorted_items


func _find_focusable_children() -> Dictionary:
	var result: Dictionary[Node, int] = {}
	var visited: Dictionary = {}
	var stack: Array[Node] = [self]

	while not stack.is_empty():
		var current_node: Node = stack.pop_back()

		if current_node in visited:
			continue
		visited[current_node] = true

		if current_node is Focusable3D and current_node != self:
			result[current_node] = current_node.index

		for child in current_node.get_children():
			if child not in visited:
				stack.push_back(child)

	return result


func _on_item_focused(index: int) -> void:
	if is_updating_focus: # Prevent re-triggering during highlight_current_item
		return
	is_mouse_hovering = true
	current_index = index
	# If keyboard navigation is not active, mouse hover should take precedence
	if not is_keyboard_navigation_active:
		highlight_current_item()


func _on_item_unfocused(_index: int) -> void:
	if is_updating_focus: # Prevent re-triggering
		return
	is_mouse_hovering = false
	if not is_keyboard_navigation_active:
		reset_highlights()


func _on_item_pressed(index: int) -> void:
	# When an item is pressed (e.g., by mouse click), set the current index.
	current_index = index
	# The highlight should already be on the item due to mouse hover/focus.
	_on_select_current_item()


func _on_move_selection(direction: int) -> void:
	# Clear mouse hover state and activate keyboard navigation
	is_mouse_hovering = false
	is_keyboard_navigation_active = true

	#  only allow horizontal movement on the top row
	var arenas_index: int = _find_item_index_by_name(&"Arenas")
	if current_index == arenas_index:
		return # Don't move left/right if on Arenas

	# Calculate new index, wrapping around the array
	current_index = wrapi(current_index + direction, 0, focusable_items.size())

	# If we wrapped onto the Arenas item, skip it
	if current_index == arenas_index:
		current_index = wrapi(
			current_index + direction, 0, focusable_items.size()
		)

	# Remember this position as the last one on the top row
	last_top_row_index = current_index

	# Highlight the newly selected item
	highlight_current_item()


# Handler for navigating UP
func _on_navigate_up() -> void:
	var arenas_index: int = _find_item_index_by_name(&"Arenas")
	# Only act if we are currently on the Arenas item
	if current_index == arenas_index:
		is_mouse_hovering = false
		is_keyboard_navigation_active = true
		# Jump back to the last remembered item on the top row
		current_index = last_top_row_index
		highlight_current_item()


# Handler for navigating DOWN
func _on_navigate_down() -> void:
	var arenas_index: int = _find_item_index_by_name(&"Arenas")
	# Only act if we are NOT on the Arenas item
	if current_index != arenas_index:
		is_mouse_hovering = false
		is_keyboard_navigation_active = true
		# Before we jump, store our current position
		last_top_row_index = current_index
		# Jump to the Arenas item
		current_index = arenas_index
		highlight_current_item()


func _on_select_current_item() -> void:
	if not _is_valid_selection():
		return
	var selected_item: Focusable3D = focusable_items[current_index]
	var item_name: StringName = selected_item.name
	if item_name in menu_actions:
		UIManager.toggle_ui(menu_actions[item_name])
		UIManager.get_viewport().set_input_as_handled()
	else:
		printerr("No action defined for item: ", item_name)


func _is_valid_selection() -> bool:
	if focusable_items.is_empty():
		printerr("Cannot select item, focusable_items list is empty!")
		return false
	# Ensure current_index is within valid bounds just in case
	if current_index < 0 or current_index >= focusable_items.size():
		printerr("Current index out of bounds: ", current_index)
		current_index = 0 # Reset to first item as a fallback
		return not focusable_items.is_empty() # Check again if list is now empty
	return true


func _on_keyboard_navigation_activated() -> void:
	is_keyboard_navigation_active = true
	is_mouse_hovering = false # Mouse hover should be secondary
	highlight_current_item() # Highlight the item at the current index


func _on_keyboard_navigation_deactivated() -> void:
	is_keyboard_navigation_active = false
	# Only reset highlights if the mouse is not hovering over an item
	if not is_mouse_hovering:
		reset_highlights()


func _unfocus_all_items() -> void:
	for item in focusable_items:
		item.unfocus()


func _preload_items() -> void:
	print("Adding UI menu items in poultry man menu...")
	# For all menu_actions, call SignalManager.add_ui_scene
	for scene_enum_value in menu_actions.values():
		if scene_enum_value == UIEnums.UI.CHICKEN_SACRIFICE:
			continue # TODO: Crack
		SignalManager.add_ui_scene.emit(scene_enum_value, {}, false)
	print("UI loaded for poultry man menu")


func reset_highlights() -> void:
	if is_updating_focus: # Prevent issues if called during a focus update
		return

	# Only reset if not hovering (keyboard nav is already false or handled by _on_keyboard_navigation_deactivated)
	if is_mouse_hovering:
		return

	is_updating_focus = true
	_unfocus_all_items()
	is_updating_focus = false


func highlight_current_item() -> void:
	if is_updating_focus or focusable_items.is_empty():
		return

	# Ensure current_index is valid before attempting to access focusable_items
	if current_index < 0 or current_index >= focusable_items.size():
		# This might happen if items are removed dynamically, adjust current_index
		if focusable_items.is_empty():
			return
		current_index = wrapi(current_index, 0, focusable_items.size())

	is_updating_focus = true
	# Ensure all items are unfocused first
	_unfocus_all_items()

	# Apply focus/highlight to the item at current_index
	if not focusable_items.is_empty() and current_index < focusable_items.size():
		# Directly call the item's focus method
		focusable_items[current_index].focus()
	is_updating_focus = false
