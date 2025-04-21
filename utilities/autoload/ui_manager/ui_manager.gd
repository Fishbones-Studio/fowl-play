################################################################################
## Manages all UI scenes in the game, handling dynamic loading, switching,
## and visibility. Also provides pause functionality and input management
## for UI elements.
################################################################################
extends CanvasLayer

var current_ui: Control # Currently active UI control
var previous_ui: Control # Previously active UI control (for navigation history)
# Stores the mouse mode before UI changes (for proper restoration)
var previous_mouse_mode: Input.MouseMode
# Dictionary mapping UI enums to their instantiated Control nodes
var ui_list: Dictionary[UIEnums.UI, Control] = {}

# Pause state with setter that manages game pause
var paused := false:
	set(value):
		paused = value
		get_tree().paused = value


func _ready() -> void:
	# Ensure UI manager processes even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	SignalManager.switch_ui_scene.connect(_on_switch_ui)
	SignalManager.add_ui_scene.connect(_on_add_ui_scene)
	# Initialize with main menu
	_on_add_ui_scene(UIEnums.UI.MAIN_MENU)


func _input(_event: InputEvent) -> void:
	# Handle pause input globally
	if Input.is_action_just_pressed("pause"):
		_handle_pause_action()
	# Handle UI cancel input globally
	elif Input.is_action_just_pressed("ui_cancel"):
		_handle_ui_cancel_action()

	
## Removes a specific UI control from the manager using its enum identifier.
##
## @param: ui_enum - The UIEnums.UI value of the UI to remove.
## @note: Handles lookup, node validity checks, and calls the main remove_ui function.
func remove_ui_by_enum(ui_enum: UIEnums.UI) -> void:
	# Check if the UI enum exists in our list
	if not ui_list.has(ui_enum):
		push_warning("Attempted to remove UI by enum, but ", UIEnums.ui_to_string(ui_enum), " was not found.")
		return

	var ui_node: Control = ui_list[ui_enum]
	if not is_instance_valid(ui_node):
		push_warning("Attempted to remove invalid UI node for ", UIEnums.ui_to_string(ui_enum))
		ui_list.erase(ui_enum)
		_cleanup_references(ui_node)
		return

	remove_ui(ui_node)

## Removes a specific UI control from the manager
##
## @param: ui - The Control node to remove
## @note: Automatically handles reference cleanup and pause state
func remove_ui(ui: Control) -> void:
	if ui not in ui_list.values():
		push_error("UI ", ui.name, " not found in ui_list")
		return

	var ui_enum: UIEnums.UI = ui_list.find_key(ui)
	
	_cleanup_references(ui)
	remove_child(ui)
	ui.queue_free()
	ui_list.erase(ui_enum)

	if ui_enum == UIEnums.UI.PAUSE_MENU and paused:
		if not _is_any_visible():
			paused = false
			_handle_mouse_mode(false)


func clear_ui() -> void:
	for ui in ui_list.values():
		if is_instance_valid(ui):
			ui.visible = false

	for child in get_children().duplicate():
		if is_instance_valid(child) and child is Control and child.get_parent() == self:
			remove_child(child)
			child.queue_free()

	ui_list.clear()
	previous_ui = null
	current_ui = null
	paused = false
	_handle_mouse_mode(false)

func toggle_ui(ui: UIEnums.UI) -> void:
	if not ui_list.has(ui):
		_on_add_ui_scene(ui)
		if ui == UIEnums.UI.PAUSE_MENU:
			var pause_menu = ui_list.get(ui)
			if is_instance_valid(pause_menu):
				pause_menu.visible = true
				move_child(pause_menu, get_child_count() - 1)
				paused = true
				_handle_mouse_mode(true)
		return

	var ui_node: Control = ui_list[ui]
	if not is_instance_valid(ui_node):
		ui_list.erase(ui)
		_on_add_ui_scene(ui)
		return

	var becoming_visible: bool = not ui_node.visible

	if becoming_visible and not _is_any_visible():
		previous_mouse_mode = Input.mouse_mode

	if becoming_visible:
		if current_ui != ui_node and is_instance_valid(current_ui):
			current_ui.visible = false
		swap_ui(current_ui, ui_node)
		ui_node.visible = true
		move_child(ui_node, get_child_count() - 1)
	else:
		ui_node.visible = false
		if current_ui == ui_node:
			var next_ui: Control = previous_ui if is_instance_valid(previous_ui) else null
			if next_ui:
				next_ui.visible = true
				move_child(next_ui, get_child_count() - 1)
			swap_ui(current_ui, next_ui)

	if ui == UIEnums.UI.PAUSE_MENU:
		paused = ui_node.visible

	_handle_mouse_mode(_is_any_visible())


func _handle_pause_action() -> void:
	# Don't allow pausing from main menu
	var main_menu = ui_list.get(UIEnums.UI.MAIN_MENU)
	if main_menu and is_instance_valid(main_menu) and current_ui == main_menu:
		return

	# Get or create pause menu
	var pause_menu = ui_list.get(UIEnums.UI.PAUSE_MENU)
	if not is_instance_valid(pause_menu):
		_on_add_ui_scene(UIEnums.UI.PAUSE_MENU)
		pause_menu = ui_list.get(UIEnums.UI.PAUSE_MENU)
		if not is_instance_valid(pause_menu):
			return

	# Toggle pause menu visibility
	if pause_menu.visible:
		# Hide pause menu
		pause_menu.visible = false
		paused = false
		
		# Restore previous UI
		var next_ui = previous_ui if is_instance_valid(previous_ui) else null
		if next_ui:
			next_ui.visible = true
			move_child(next_ui, get_child_count() - 1)
		swap_ui(pause_menu, next_ui)
	else:
		# Show pause menu
		if not _is_any_visible():
			previous_mouse_mode = Input.mouse_mode
			
		if is_instance_valid(current_ui) and current_ui.visible:
			current_ui.visible = false
			
		pause_menu.visible = true
		if pause_menu.get_parent() == self:
			move_child(pause_menu, get_child_count() - 1)

		paused = true
		paused = true
		swap_ui(
			current_ui if is_instance_valid(current_ui) else null,
			pause_menu if is_instance_valid(pause_menu) else null
		)

	_handle_mouse_mode(_is_any_visible())


func _handle_ui_cancel_action() -> void:
	var main_menu = ui_list.get(UIEnums.UI.MAIN_MENU)
	if main_menu and is_instance_valid(main_menu) and current_ui == main_menu:
		return

	if is_instance_valid(current_ui) and current_ui.visible:
		var was_pause_menu = (ui_list.find_key(current_ui) == UIEnums.UI.PAUSE_MENU)
		current_ui.visible = false
		
		var next_ui = previous_ui if is_instance_valid(previous_ui) else null
		if next_ui and next_ui != current_ui:
			next_ui.visible = true
			move_child(next_ui, get_child_count() - 1)
			
		swap_ui(current_ui, next_ui)
		
		if was_pause_menu:
			paused = false
			
		_handle_mouse_mode(_is_any_visible())


func _cleanup_references(ui_node: Control) -> void:
	if current_ui == ui_node:
		current_ui = null
	if previous_ui == ui_node:
		previous_ui = null
		
	if current_ui == null and is_instance_valid(previous_ui):
		current_ui = previous_ui
		previous_ui = null
		if is_instance_valid(current_ui):
			current_ui.visible = true
			move_child(current_ui, get_child_count() - 1)
			_handle_mouse_mode(true)
		elif not _is_any_visible():
			_handle_mouse_mode(false)


func _handle_mouse_mode(value: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else previous_mouse_mode


func _is_any_visible() -> bool:
	for ui_enum in ui_list:
		if ui_enum == UIEnums.UI.PLAYER_HUD:
			continue
			
		var node = ui_list[ui_enum]
		if not is_instance_valid(node):
			ui_list.erase(ui_enum)
			continue
			
		if node.visible:
			return true
			
	return false


## Completely switches to a new UI scene using clear_ui first.
## Use this for major state changes (e.g., Menu -> Game).
##
## @param: new_ui - The UI enum to switch to
## @param: params - Optional parameters to pass to the new UI
func _on_switch_ui(new_ui: UIEnums.UI, params: Dictionary = {}) -> void:
	clear_ui()
	_on_add_ui_scene(new_ui, params)


## Adds and initializes a new UI scene.
## Pause Menu starts hidden by default.
##
## @param: new_ui - The UI enum to add
## @param: params - Dictionary of initialization parameters
func _on_add_ui_scene(new_ui: UIEnums.UI, params: Dictionary = {}) -> void:
	# If an instance already exists, reuse it (do not create a new one)
	if ui_list.has(new_ui) and is_instance_valid(ui_list[new_ui]):
		var existing_node = ui_list[new_ui]
		if current_ui != existing_node and new_ui != UIEnums.UI.PAUSE_MENU:
			if not existing_node.visible and not _is_any_visible():
				previous_mouse_mode = Input.mouse_mode
			if is_instance_valid(current_ui):
				current_ui.visible = false
			swap_ui(current_ui, existing_node)
			current_ui.visible = true
			if current_ui.get_parent() == self:
				move_child(current_ui, get_child_count() - 1)
			_handle_mouse_mode(true)
		return

	# If a previous instance exists but is not valid, remove it from the list
	if ui_list.has(new_ui) and not is_instance_valid(ui_list[new_ui]):
		ui_list.erase(new_ui)

	# Load and instance the new UI scene
	var new_ui_path = UIEnums.PATHS.get(new_ui, "")
	if new_ui_path.is_empty():
		push_error("No path defined for UI enum: ", new_ui)
		return

	var new_ui_resource: Resource = ResourceLoader.load(new_ui_path)
	if not new_ui_resource or not new_ui_resource is PackedScene:
		push_error("Failed to load UI scene at path: ", new_ui_path)
		return

	var new_ui_node = new_ui_resource.instantiate()
	if not new_ui_node is Control:
		if is_instance_valid(new_ui_node):
			new_ui_node.queue_free()
		push_error("Instantiated scene root is not a Control node: ", new_ui_path)
		return

	var should_be_visible = new_ui != UIEnums.UI.PAUSE_MENU
	if should_be_visible and not _is_any_visible():
		previous_mouse_mode = Input.mouse_mode

	if new_ui_node.has_method("setup"):
		new_ui_node.setup(params)

	# Connect signals and store callables for later disconnection
	var tree_exited_callable = func():
		SignalManager.ui_disabled.emit(previous_ui)
	new_ui_node.set_meta("_tree_exited_callable", tree_exited_callable)
	new_ui_node.tree_exited.connect(tree_exited_callable)

	var visibility_changed_callable = func():
		if not new_ui_node.visible:
			SignalManager.ui_disabled.emit(previous_ui)
	new_ui_node.set_meta("_visibility_changed_callable", visibility_changed_callable)
	new_ui_node.visibility_changed.connect(visibility_changed_callable)

	# Disconnect those signals from the previous UI
	if is_instance_valid(previous_ui):
		if previous_ui.has_meta("_tree_exited_callable"):
			previous_ui.tree_exited.disconnect(previous_ui.get_meta("_tree_exited_callable"))
			previous_ui.set_meta("_tree_exited_callable", null)
		if previous_ui.has_meta("_visibility_changed_callable"):
			previous_ui.visibility_changed.disconnect(previous_ui.get_meta("_visibility_changed_callable"))
			previous_ui.set_meta("_visibility_changed_callable", null)

	# Remove any previous instance of this UI type from the scene tree
	if ui_list.has(new_ui):
		var old_node = ui_list[new_ui]
		if is_instance_valid(old_node) and old_node.get_parent() == self:
			remove_child(old_node)
			old_node.queue_free()
		ui_list.erase(new_ui)

	add_child(new_ui_node)
	ui_list[new_ui] = new_ui_node

	if should_be_visible:
		if is_instance_valid(current_ui):
			current_ui.visible = false
		swap_ui(current_ui, new_ui_node)
		current_ui.visible = true
		if current_ui.get_parent() == self:
			move_child(current_ui, get_child_count() - 1)
	else:
		new_ui_node.visible = false

	_handle_mouse_mode(_is_any_visible())


## Swaps the current and previous UI references
##
## @param: prev_ui - The UI control being replaced
## @param: curr_ui - The new UI control to make current
## @note: Handles null/invalid instances safely
func swap_ui(prev_ui: Control, curr_ui: Control) -> void:
	previous_ui = prev_ui if is_instance_valid(prev_ui) else null
	current_ui = curr_ui if is_instance_valid(curr_ui) else null
