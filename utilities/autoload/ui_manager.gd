################################################################################
## Manages all UI scenes in the game, handling dynamic loading, switching,
## and visibility. Also provides pause functionality and input management
## for UI elements.
################################################################################
extends CanvasLayer

var current_ui: Control: # Currently active UI control
	set(value):
		# Prevent setting current UI to the same value
		if current_ui == value:
			return
		current_ui = value
		# Update game input blocked state based on the new UI
		_update_game_input_blocked()
		_update_game_mouse_mode()

var previous_ui: Control # Previously active UI control (for navigation history)
# Dictionary mapping UI enums to their instantiated Control nodes
var ui_list: Dictionary[UIEnums.UI, Control] = {}

# Pause state with setter that manages game pause
var paused: bool = false:
	set(value):
		# Prevent setting pause state if it's already the target value
		if paused == value:
			return
		paused = value
		get_tree().paused = value

## Flag to block game input when certain UI elements are active
var game_input_blocked: bool = false


func _ready() -> void:
	# Ensure UI manager processes even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	SignalManager.switch_ui_scene.connect(_on_switch_ui)
	SignalManager.add_ui_scene.connect(_on_add_ui_scene)

	# Initialize with main menu
	_on_add_ui_scene(UIEnums.UI.MAIN_MENU)

	layer = 3


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		handle_pause()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") && _is_any_visible():
		var focused: Control = get_viewport().gui_get_focus_owner()

		if focused is LineEdit or focused is TextEdit:
			# Let text controls handle it naturally
			get_viewport().set_input_as_handled()
			return

		_handle_ui_cancel_action()


## Loads a game scene with a loading screen, then switches to HUD and target game scene
##
## @param: game_scene_path - The resource path or UID to the game scene
## @param: next_ui - Optional: Which HUD UI to show after loading (default: PLAYER_HUD)
func load_game_with_loading_screen(game_scene_enum: SceneEnums.Scenes, next_ui: UIEnums.UI = UIEnums.UI.PLAYER_HUD, next_ui_params: Dictionary = {}, game_params: Dictionary = {}) -> void:
	# Show the loading screen UI
	SignalManager.switch_ui_scene.emit(UIEnums.UI.LOADING_SCREEN)

	# Notify that the loading screen has started
	SignalManager.loading_screen_started.emit(next_ui, next_ui_params)

	await get_tree().process_frame

	# Switch to the loaded game scene
	SignalManager.emit_throttled("switch_game_scene", [game_scene_enum, game_params])


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
		return

	remove_ui(ui_node)


## Removes a specific UI control from the manager
##
## @param: ui - The Control node to remove
## @note: Automatically handles reference cleanup and pause state
func remove_ui(ui: Control) -> void:
	# Check if UI exists in our list and is valid
	if not is_instance_valid(ui) or ui not in ui_list.values():
		push_warning("Attempted to remove UI '%s' not found in ui_list or invalid." % ui.name if is_instance_valid(ui) else "INVALID")
		var key_to_remove = ui_list.find_key(ui)
		if key_to_remove != null:
			ui_list.erase(key_to_remove)
		return

	var ui_enum: UIEnums.UI = ui_list.find_key(ui)

	# Handle references before removing
	if current_ui == ui:
		current_ui = previous_ui if (is_instance_valid(previous_ui) && ui_list.find_key(previous_ui) not in UIEnums.UI_EXCEMPT_VISIBLE_CHECK ) else null
		# If current_ui is null, check once more if the player hud is visible or not
		if not is_instance_valid(current_ui) and not _is_any_visible():
			current_ui = ui_list.get(UIEnums.UI.PLAYER_HUD) if ui_list.has(UIEnums.UI.PLAYER_HUD) else null
		previous_ui = null
		if is_instance_valid(current_ui):
			current_ui.visible = true
			move_child(current_ui, get_child_count() - 1)
	elif previous_ui == ui:
		previous_ui = null

	# Remove from scene tree and dictionary
	if ui.get_parent() == self:
		remove_child(ui)
	ui.queue_free()
	ui_list.erase(ui_enum)

	# Update pause state and mouse mode if necessary
	if ui_enum == UIEnums.UI.PAUSE_MENU and paused:
		paused = false


## Clears all UI elements from the manager
##
## @note: Completely resets the UI state, removing all controls from the manager
func clear_ui() -> void:
	for child in get_children().duplicate():
		if child is Control and ui_list.values().has(child):
			var ui_enum = ui_list.find_key(child)
			if ui_enum != null:
				ui_list.erase(ui_enum)
			remove_child(child)
			child.queue_free()

	ui_list.clear()
	previous_ui = null
	current_ui = null
	paused = false


## Swaps the current and previous UI references
##
## @param: prev_ui - The UI control being replaced
## @param: curr_ui - The new UI control to make current
## @note: Handles null/invalid instances safely
func swap_ui(prev_ui: Control, curr_ui: Control) -> void:
	previous_ui = prev_ui if is_instance_valid(prev_ui) else null
	current_ui = curr_ui if is_instance_valid(curr_ui) else null

	print("Current UI: ", current_ui, " | Prev UI: ", previous_ui)
	if current_ui and previous_ui:
		print("Current UI visible: ", current_ui.visible, " | Prev UI visibile: ", previous_ui.visible)


## Toggles visibility of a specific UI
## Use this for overlays like Inventory, Map, etc., not for Pause or main switching.
##
## @param: ui_enum - The UI enum to toggle
## @note: Brings UI to front when showing, manages focus automatically
func toggle_ui(ui_enum: UIEnums.UI) -> void:
	if ui_enum == UIEnums.UI.PAUSE_MENU:
		push_warning("Use handle_pause() to toggle the pause menu, not toggle_ui().")
		handle_pause()
		return

	if not ui_list.has(ui_enum):
		_on_add_ui_scene(ui_enum)
		return

	var ui_to_toggle: Control = ui_list.get(ui_enum)
	if not is_instance_valid(ui_to_toggle):
		push_error("UI node for ", UIEnums.ui_to_string(ui_enum), " is invalid.")
		ui_list.erase(ui_enum)
		return

	var becoming_visible: bool = not ui_to_toggle.visible

	if becoming_visible:
		if is_instance_valid(current_ui) and current_ui != ui_to_toggle:
			current_ui.visible = false
			swap_ui(current_ui, ui_to_toggle)
		elif not is_instance_valid(current_ui):
			swap_ui(null, ui_to_toggle)

		ui_to_toggle.visible = true
		move_child(ui_to_toggle, get_child_count() - 1)
	else:
		# Hiding the UI (This case is now primarily handled by _handle_ui_cancel_action)
		# We keep the logic here in case toggle_ui is called directly to hide
		ui_to_toggle.visible = false
		if current_ui == ui_to_toggle:
			var next_ui = previous_ui if is_instance_valid(previous_ui) else null
			swap_ui(current_ui, next_ui)
			if is_instance_valid(current_ui):
				current_ui.visible = true
				move_child(current_ui, get_child_count() - 1)


## Handles pause state and UI visibility changes
##
## @note: Manages the complex interplay between pause menu and other UIs
func handle_pause() -> void:
	# check if any ui, besides HUD and/or pause menu, is visible
	if _is_any_visible_besides_list(UIEnums.UI_EXCEMPT_VISIBLE_CHECK):
		push_warning("Attempted to pause while other UI is visible. Ignoring.")
		_handle_ui_cancel_action()
		return

	var pause_menu: Control = ui_list.get(UIEnums.UI.PAUSE_MENU)

	if not is_instance_valid(pause_menu):
		_on_add_ui_scene(UIEnums.UI.PAUSE_MENU, {}, false)
		pause_menu = ui_list.get(UIEnums.UI.PAUSE_MENU)
		if not is_instance_valid(pause_menu):
			push_error("Failed to instantiate Pause Menu!")
			return

	var is_pausing: bool = not paused

	if is_pausing:

		if is_instance_valid(current_ui) and current_ui:
			current_ui.visible = ui_list.find_key(current_ui) in UIEnums.UI_MOUSE_CAPTURED
			swap_ui(current_ui, pause_menu)
		elif not is_instance_valid(current_ui):
			swap_ui(null, pause_menu)

		pause_menu.visible = true
		move_child(pause_menu, get_child_count() - 1)
		paused = true
	else:
		# Unpausing (can be triggered by pause button or ui_cancel)
		pause_menu.visible = false
		paused = false

		var ui_to_restore = previous_ui if is_instance_valid(previous_ui) else null
		# if null and player hud is not visible, set to player hud
		if ui_to_restore == null and not _is_any_visible():
			ui_to_restore = ui_list.get(UIEnums.UI.PLAYER_HUD) if ui_list.has(UIEnums.UI.PLAYER_HUD) else null

		swap_ui(pause_menu, ui_to_restore)


## Handles the "ui_cancel" input action (e.g., Escape key)
## Used to back out of UI screens like inventory, map, or pause menu.
func _handle_ui_cancel_action() -> void:
	# Do nothing if main menu or loading screen is active
	for ui_enum: UIEnums.UI in [UIEnums.UI.MAIN_MENU, UIEnums.UI.LOADING_SCREEN]:
		var ui: Control = ui_list.get(ui_enum)
		if ui and is_instance_valid(ui) and current_ui == ui and ui.visible:
			return

	# If pause menu is active, treat cancel as unpause
	var pause_menu = ui_list.get(UIEnums.UI.PAUSE_MENU)
	if pause_menu and is_instance_valid(pause_menu) and current_ui == pause_menu and pause_menu.visible:
		handle_pause() # Call handle_pause to perform the unpause logic
		return

	# If any other valid UI is currently active and visible (and not the HUD)
	if is_instance_valid(current_ui) and current_ui.visible and ui_list.find_key(current_ui) not in UIEnums.UI_MOUSE_CAPTURED:
		current_ui.visible = false # Hide the current UI

		# Determine the UI to switch back to (the previous one)
		var next_ui = previous_ui if is_instance_valid(previous_ui) else null

		# Swap references: the one we just hid becomes previous, next_ui becomes current
		swap_ui(current_ui, next_ui)

		# Make the new current UI visible (if it exists)
		if is_instance_valid(current_ui):
			current_ui.visible = true
			move_child(current_ui, get_child_count() - 1) # Bring it to front

		return

	# If no specific UI is active (e.g., only HUD is visible), do nothing on cancel


## checks if any UI, besides the passed in list of enums, is currently visible
func _is_any_visible_besides_list(ui_exceptions: Array[UIEnums.UI]) -> bool:
	for ui_enum in ui_list:
		if ui_enum in ui_exceptions:
			continue

		var node = ui_list[ui_enum]
		if is_instance_valid(node) and node.visible:
			return true

	return false


## Checks if any UI (excluding Player HUD) is currently visible
func _is_any_visible() -> bool:
	for ui_enum in ui_list:
		if ui_enum in UIEnums.UI_MOUSE_CAPTURED:
			continue

		var node = ui_list[ui_enum]
		if is_instance_valid(node) and node.visible:
			return true
		
	return false


## Completely switches to a new UI scene (e.g., Main Menu -> Game HUD)
##
## @param: new_ui_enum - The UI enum to switch to
## @param: params - Optional parameters to pass to the new UI's setup method
func _on_switch_ui(new_ui_enum: UIEnums.UI, params: Dictionary = {}) -> void:
	clear_ui()
	_on_add_ui_scene(new_ui_enum, params)


## Adds and initializes a new UI scene instance.
## Assumes the new UI should be visible unless specified otherwise.
##
## @param: new_ui_enum - The UI enum to add
## @param: params - Dictionary of initialization parameters for setup method
## @param: make_visible - Should the UI be immediately visible? (Defaults true)
func _on_add_ui_scene(new_ui_enum: UIEnums.UI, params: Dictionary = {}, make_visible: bool = true) -> void:
	if new_ui_enum == UIEnums.UI.NULL:
		print("Ui enum null passed, skipping")
		return
	
	if ui_list.has(new_ui_enum) and is_instance_valid(ui_list[new_ui_enum]):
		push_warning("Attempted to add UI '", UIEnums.ui_to_string(new_ui_enum), "' which already exists.")
		if make_visible and not ui_list[new_ui_enum].visible:
			# If trying to add an existing UI and make it visible, use toggle_ui logic
			# But avoid calling toggle_ui directly for pause menu
			if new_ui_enum == UIEnums.UI.PAUSE_MENU:
				handle_pause()
			else:
				toggle_ui(new_ui_enum)
		return

	var new_ui_path: String = UIEnums.PATHS.get(new_ui_enum, "")
	if new_ui_path.is_empty():
		push_error("Error: No path defined for UI enum: ", UIEnums.ui_to_string(new_ui_enum))
		return
	var new_ui_resource: Resource = ResourceLoader.load(new_ui_path)

	if not new_ui_resource:
		push_error("Error: Could not load UI scene at path: ", new_ui_path)
		return
	if not new_ui_resource is PackedScene:
		push_error("Error: Resource at path is not a PackedScene: ", new_ui_path)
		return

	var new_ui_node: Node = new_ui_resource.instantiate()
	if not new_ui_node is Control:
		push_error("Error: Instantiated scene root is not a Control node: ", new_ui_path)
		if is_instance_valid(new_ui_node):
			new_ui_node.queue_free()
		return

	if new_ui_node.has_method("setup"):
		new_ui_node.setup(params)

	add_child(new_ui_node)
	ui_list[new_ui_enum] = new_ui_node

	if make_visible:

		swap_ui(current_ui, new_ui_node)

		new_ui_node.visible = true
		move_child(new_ui_node, get_child_count() - 1)
	else:
		new_ui_node.visible = false


## Updates the game_input_blocked state based on the current UI
## This function checks if any UI that blocks game input is currently active.
func _update_game_input_blocked() -> void:
	if not current_ui: 
		game_input_blocked = false
		return
	var ui_enum : UIEnums.UI = ui_list.find_key(current_ui)
	if ui_enum == null:
		game_input_blocked = false
		return
	# Check if any UI is visible and set game_input_blocked accordingly
	game_input_blocked = UIEnums.UI_BLOCK_GAME_INPUT.has(ui_enum)


## Sets the mouse mode based on the currently active UI.
## If no UI is active, it checks for visible background UIs (like a HUD) to determine the mouse state.
func _update_game_mouse_mode() -> void:
	var desired_mode: Input.MouseMode

	if is_instance_valid(current_ui):
		# A primary UI (like a menu) is active.
		# Base the mouse mode on this specific UI.
		var ui_enum: UIEnums.UI = ui_list.find_key(current_ui)

		if ui_enum in UIEnums.UI_MOUSE_CAPTURED:
			desired_mode = Input.MOUSE_MODE_CAPTURED
		else:
			# Any other active UI (pause menu, inventory) makes mouse visible.
			desired_mode = Input.MOUSE_MODE_VISIBLE
	else:
		# No primary UI is active
		# Default to visible unless a "captured" UI (like a HUD) is visible.
		desired_mode = Input.MOUSE_MODE_VISIBLE
		for ui_enum in UIEnums.UI_MOUSE_CAPTURED:
			var ui_node: Control = ui_list.get(ui_enum)
			if is_instance_valid(ui_node) and ui_node.visible:
				# Found a visible HUD or other capture-type UI.
				desired_mode = Input.MOUSE_MODE_CAPTURED
				break # Found one, no need to check others.

	# Apply the determined mouse mode only if it has changed.
	if Input.mouse_mode != desired_mode:
		Input.mouse_mode = desired_mode
		print(
			"Mouse mode set to: ",
			"CAPTURED"
			if desired_mode == Input.MOUSE_MODE_CAPTURED
			else "VISIBLE"
		)
