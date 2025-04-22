extends Node3D

# Exported Variables
@export var input_handler: Node
@export var light_handler: Node

# Navigation State
var current_index: int = 0
var is_keyboard_navigation_active: bool = false
var is_mouse_hovering: bool = false
var focusable_items: Array[Focusable3D] = []

@onready var flyer_item: Focusable3D = $MenuItems/Flyer  
@onready var shop_item: Focusable3D = $MenuItems/Shop
@onready var inventory_item: Focusable3D = $MenuItems/Inventory


func _ready() -> void:
	UIManager.remove_ui_by_enum(UIEnums.UI.PLAYER_HUD)
	
	# Get all focusable items
	focusable_items = _get_focusable_items()

	if focusable_items.is_empty():
		print("No focusable items found. Disabling navigation.")
		return

	# Connect signals for each item
	for i in focusable_items.size():
		var item: Focusable3D = focusable_items[i]
		item.focused.connect(_on_item_focused.bind(i))
		item.unfocused.connect(_on_item_unfocused.bind(i))
		item.pressed.connect(_on_item_pressed.bind(i))

	# Connect input handler signals
	if input_handler:
		input_handler.selection_moved.connect(_on_move_selection)
		input_handler.current_item_selected.connect(_on_select_current_item)
		input_handler.keyboard_navigation_activated.connect(_on_keyboard_navigation_activated)
		input_handler.keyboard_navigation_deactivated.connect(_on_keyboard_navigation_deactivated)

	# Reset highlights initially (will be overwritten by initial focus)
	reset_highlights()
	
	# Find the index of the flyer_item in the focusable_items array
	var flyer_index: int = focusable_items.find(flyer_item)

	if flyer_index != -1:
		current_index = flyer_index
		is_keyboard_navigation_active = true # Act as if keyboard nav is active for initial focus
		highlight_current_item() # Highlight and grab focus of the flyer item
	else:
		printerr("Flyer item not found in focusable_items array!")
		# Fallback: grab focus of the first item if flyer is not found
		if not focusable_items.is_empty():
			current_index = 0
			is_keyboard_navigation_active = true # Act as if keyboard nav is active
			highlight_current_item() # Highlight and grab focus of the first item


func _get_focusable_items() -> Array[Focusable3D]:
	var items: Array[Focusable3D] = []
	# Get all nodes in the "focusable_items" group and filter for Focusable3D
	var all_nodes: Array[Node] = get_tree().get_nodes_in_group("focusable_items")
	for node in all_nodes:
		if node is Focusable3D:
			items.append(node)

	# If no items are found via the group, try finding Focusable3D children
	if items.is_empty():
		items = _find_focusable_children(self)

	return items


func _find_focusable_children(node: Node) -> Array[Focusable3D]:
	var result: Array[Focusable3D] = []
	for child in node.get_children():
		if child is Focusable3D:
			result.append(child)
		# Recursively search in children's children
		result.append_array(_find_focusable_children(child))
	return result


func _on_item_focused(index: int) -> void:
	is_mouse_hovering = true
	current_index = index


func _on_item_unfocused(_index: int) -> void:
	is_mouse_hovering = false
	if not is_keyboard_navigation_active:
		reset_highlights()
	else:
		highlight_current_item()


func _on_item_pressed(index: int) -> void:
	# When an item is pressed (either by mouse click or ui_accept while focused),
	# set the current index and *activate* keyboard navigation state temporarily
	# so that highlight_current_item() works correctly right before calling the action.
	current_index = index
	# is_keyboard_navigation_active = true # Might not always want this on click/press
	highlight_current_item() # Ensures the pressed item remains highlighted briefly
	_on_select_current_item()
	# is_keyboard_navigation_active = false # You might reset it here if clicking should deactivate keyboard mode


func _on_move_selection(direction: int) -> void:
	# Clear mouse hover state and activate keyboard navigation
	is_mouse_hovering = false
	is_keyboard_navigation_active = true

	# Calculate new index, wrapping around the array
	current_index = wrapi(current_index + direction, 0, focusable_items.size())

	# Highlight the newly selected item
	highlight_current_item()


func _on_select_current_item() -> void:
	if focusable_items.is_empty():
		printerr("Cannot select item, focusable_items list is empty!")
		return

	# Ensure current_index is within valid bounds just in case
	if current_index < 0 or current_index >= focusable_items.size():
		printerr("Current index out of bounds: ", current_index)
		current_index = 0 # Reset to first item as a fallback
		if focusable_items.is_empty(): return # Check again if list is now empty
		
	var selected_item: Focusable3D = focusable_items[current_index]

	if selected_item == flyer_item:
		SignalManager.emit_throttled("switch_ui_scene", [UIEnums.UI.PLAYER_HUD])
		SignalManager.emit_throttled("switch_game_scene", ["uid://bhnqi4fnso1hh"])
	elif selected_item == shop_item:
		if UIEnums.UI.POULTRYMAN_SHOP in UIManager.ui_list:
			UIManager.toggle_ui(UIEnums.UI.POULTRYMAN_SHOP)
		else:
			SignalManager.add_ui_scene.emit(UIEnums.UI.POULTRYMAN_SHOP)
	elif selected_item == inventory_item:
		if UIEnums.UI.CHICKEN_INVENTORY in UIManager.ui_list:
			UIManager.toggle_ui(UIEnums.UI.CHICKEN_INVENTORY)
		else:
			SignalManager.add_ui_scene.emit(UIEnums.UI.CHICKEN_INVENTORY)


func _on_keyboard_navigation_activated() -> void:
	is_keyboard_navigation_active = true
	is_mouse_hovering = false # Mouse hover should be secondary
	highlight_current_item() # Highlight the item at the current index


func _on_keyboard_navigation_deactivated() -> void:
	is_keyboard_navigation_active = false
	# Only reset highlights if the mouse is not hovering over an item
	if not is_mouse_hovering:
		reset_highlights()


func reset_highlights() -> void:
	# Only reset if not hovering and not in keyboard navigation
	if is_mouse_hovering or is_keyboard_navigation_active:
		return

	_unfocus_all_items()


func highlight_current_item() -> void:
	# Ensure all items are unfocused first
	_unfocus_all_items()

	# Apply focus/highlight to the item at current_index
	# if keyboard navigation is active OR mouse is hovering, and the list isn't empty.
	if not focusable_items.is_empty():
		# Directly call the item's focus method
		focusable_items[current_index].focus()


func _unfocus_all_items() -> void:
	for item in focusable_items:
		item.unfocus()
