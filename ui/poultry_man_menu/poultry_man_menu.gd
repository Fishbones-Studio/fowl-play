extends Node3D

# Exported Variables
@export var input_handler: Node
@export var default_focused_item_name: StringName = &"Arenas"

# Input Mode Management
enum InputMode {
	NONE,
	MOUSE,
	KEYBOARD,
	CONTROLLER
}

# Navigation State
var current_index: int = 0
var current_input_mode: InputMode = InputMode.NONE
var focusable_items: Array[Focusable3D] = []
var currently_focused_item: Focusable3D = null
var last_top_row_index: int = 1 # Default to a central item

# Variable to track the last non-mouse input device
var last_nav_device: InputMode = InputMode.KEYBOARD

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
	_set_initial_focus()
	_preload_items()


# Use _input to track the last used device type
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		last_nav_device = InputMode.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		last_nav_device = InputMode.CONTROLLER


func _initialize_focusable_items() -> void:
	focusable_items = _get_focusable_items()

	if focusable_items.is_empty():
		printerr("No focusable items found. Disabling navigation.")
		return

	# Connect signals for each item - but handle them differently
	for i in focusable_items.size():
		var item: Focusable3D = focusable_items[i]
		# Connect to mouse events directly instead of using focus signals
		item.mouse_entered.connect(_on_item_mouse_entered.bind(item, i))
		item.mouse_exited.connect(_on_item_mouse_exited.bind(item, i))
		item.pressed.connect(_on_item_pressed.bind(i))


func _connect_input_signals() -> void:
	if not input_handler:
		return

	input_handler.selection_moved.connect(_on_move_selection)
	input_handler.current_item_selected.connect(_on_select_current_item)
	input_handler.navigate_up_pressed.connect(_on_navigate_up)
	input_handler.navigate_down_pressed.connect(_on_navigate_down)
	input_handler.keyboard_navigation_activated.connect(
		_on_keyboard_navigation_activated
	)


func _set_initial_focus() -> void:
	if focusable_items.is_empty():
		return

	var default_index: int = _find_item_index_by_name(
		default_focused_item_name
	)
	current_index = max(0, default_index)

	var arenas_index: int = _find_item_index_by_name(&"Arenas")
	if current_index != arenas_index:
		last_top_row_index = current_index

	# Start in keyboard mode with initial focus
	_switch_input_mode(InputMode.KEYBOARD)
	_set_focus_to_index(current_index)


# Core focus management - only one source of truth
func _set_focus_to_item(item: Focusable3D) -> void:
	if currently_focused_item == item:
		return # Already focused

	# Unfocus current item
	if currently_focused_item != null:
		currently_focused_item.unfocus()

	# Focus new item
	currently_focused_item = item
	if item != null:
		item.focus()


func _set_focus_to_index(index: int) -> void:
	if index < 0 or index >= focusable_items.size():
		return

	current_index = index
	_set_focus_to_item(focusable_items[index])


func _clear_focus() -> void:
	if currently_focused_item != null:
		currently_focused_item.unfocus()
		currently_focused_item = null


# Input mode switching
func _switch_input_mode(new_mode: InputMode) -> void:
	if current_input_mode == new_mode:
		return

	var old_mode: InputMode = current_input_mode
	current_input_mode = new_mode

	print(
		"Input mode changed: ",
		InputMode.keys()[old_mode],
		" -> ",
		InputMode.keys()[new_mode]
	)

	match new_mode:
		InputMode.MOUSE:
			# Mouse mode - focus is handled by mouse events
			pass
		InputMode.KEYBOARD, InputMode.CONTROLLER:
			# Navigation mode - ensure current index item is focused
			_set_focus_to_index(current_index)
		InputMode.NONE:
			# No input mode - clear focus
			_clear_focus()


# Mouse event handlers
func _on_item_mouse_entered(item: Focusable3D, index: int) -> void:
	_switch_input_mode(InputMode.MOUSE)
	current_index = index
	_set_focus_to_item(item)


func _on_item_mouse_exited(item: Focusable3D, _index: int) -> void:
	# Only clear focus if we're in mouse mode and this item is currently focused
	if current_input_mode == InputMode.MOUSE and currently_focused_item == item:
		_clear_focus()


func _on_item_pressed(index: int) -> void:
	current_index = index
	_on_select_current_item()


# Keyboard/Controller navigation
func _on_move_selection(direction: int) -> void:
	# Use the last detected navigation device
	_switch_input_mode(last_nav_device)

	var arenas_index: int = _find_item_index_by_name(&"Arenas")
	if current_index == arenas_index:
		return # Don't move left/right if on Arenas

	# Calculate new index, wrapping around the array
	var new_index: int = wrapi(
		current_index + direction,
		0,
		focusable_items.size()
	)

	# If we wrapped onto the Arenas item, skip it
	if new_index == arenas_index:
		new_index = wrapi(new_index + direction, 0, focusable_items.size())

	# Remember this position as the last one on the top row
	last_top_row_index = new_index

	_set_focus_to_index(new_index)


func _on_navigate_up() -> void:
	# Use the last detected navigation device
	_switch_input_mode(last_nav_device)

	var arenas_index: int = _find_item_index_by_name(&"Arenas")
	if current_index == arenas_index:
		_set_focus_to_index(last_top_row_index)


func _on_navigate_down() -> void:
	# Use the last detected navigation device
	_switch_input_mode(last_nav_device)

	var arenas_index: int = _find_item_index_by_name(&"Arenas")
	if current_index != arenas_index:
		last_top_row_index = current_index
		_set_focus_to_index(arenas_index)


func _on_keyboard_navigation_activated() -> void:
	# Use the last detected navigation device
	_switch_input_mode(last_nav_device)


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


# Helper functions (unchanged)
func _find_item_index_by_name(item_name: StringName) -> int:
	for i in focusable_items.size():
		if focusable_items[i].name == item_name:
			return i
	printerr(item_name + " not found in focusable_items array!")
	return -1


func _get_focusable_items() -> Array[Focusable3D]:
	var items: Dictionary = {}
	var group_nodes: Array[Node] = get_tree().get_nodes_in_group(
		"focusable_items"
	)

	for node in group_nodes:
		if node is Focusable3D and is_ancestor_of(node):
			items[node] = node.index

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


func _is_valid_selection() -> bool:
	if focusable_items.is_empty():
		printerr("Cannot select item, focusable_items list is empty!")
		return false

	if current_index < 0 or current_index >= focusable_items.size():
		printerr("Current index out of bounds: ", current_index)
		current_index = 0
		return not focusable_items.is_empty()

	return true


func _preload_items() -> void:
	print("Adding UI menu items in poultry man menu...")
	for scene_enum_value in menu_actions.values():
		if scene_enum_value == UIEnums.UI.CHICKEN_SACRIFICE:
			continue # TODO: Crack
		SignalManager.add_ui_scene.emit(scene_enum_value, {}, false)
	print("UI loaded for poultry man menu")
