################################################################################
## Manages all UI scenes in the game, handling dynamic loading, switching,
## and visibility. Also provides pause functionality and input management
## for UI elements.
################################################################################
extends CanvasLayer

var current_ui: Control # Currently active UI control
var previous_ui: Control # Previously active UI control (for navigation history)
# Stores the mouse mode before UI changes (for proper restoration)
var previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
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
		print("Pause action triggered")
		_handle_pause_action()
	# Handle UI cancel input globally
	elif Input.is_action_just_pressed("ui_cancel"):
		_handle_ui_cancel_action()


## Removes a specific UI control from the manager
##
## @param: ui - The Control node to remove
## @note: Automatically handles reference cleanup and pause state
func remove_ui(ui: Control) -> void:
	# Check if UI exists in our list
	if ui not in ui_list.values():
		push_error("UI ", ui.name, " not found in ui_list")
		return

	var ui_enum: UIEnums.UI = ui_list.find_key(ui)

	# Handle references
	if current_ui == ui:
		current_ui = null
	if previous_ui == ui:
		previous_ui = null

	# Remove from scene tree and dictionary
	remove_child(ui)
	ui.queue_free()
	if ui_list.has(ui_enum): # Check if key exists before erasing
		ui_list.erase(ui_enum)

	# Update pause state if the removed UI was the pause menu and visible
	if ui_enum == UIEnums.UI.PAUSE_MENU and paused:
		# If removing the pause menu, ensure game isn't stuck paused
		# Check if any *other* UI is visible that might keep it paused
		if not _is_any_visible():
			paused = false
			_handle_mouse_mode(false) # Restore previous mouse mode if no UI left

	# If the removed UI was the current one, try to restore previous
	if current_ui == null and is_instance_valid(previous_ui):
		current_ui = previous_ui
		previous_ui = null
		if is_instance_valid(current_ui):
			current_ui.visible = true
			move_child(current_ui, get_child_count() - 1)
			_handle_mouse_mode(true)


## Clears all UI elements from the manager
##
## @note: Completely resets the UI state, removing all controls from the manager
func clear_ui() -> void:
	# Hide all ui nodes first to potentially trigger signals if needed
	for ui_key in ui_list:
		if is_instance_valid(ui_list[ui_key]):
			ui_list[ui_key].visible = false

	# Remove and free all child nodes managed by this layer
	for child in get_children():
		remove_child(child)
		child.queue_free()

	ui_list.clear()

	# Reset state
	previous_ui = null
	current_ui = null
	paused = false # Ensure game is unpaused
	_handle_mouse_mode(false) # Restore original mouse mode


## Swaps the current and previous UI references
##
## @param: prev_ui - The UI control being replaced
## @param: curr_ui - The new UI control to make current
## @note: Handles null/invalid instances safely
func swap_ui(prev_ui: Control, curr_ui: Control) -> void:
	previous_ui = prev_ui if is_instance_valid(prev_ui) else null
	current_ui = curr_ui if is_instance_valid(curr_ui) else null


## Toggles visibility of a specific UI
##
## @param: ui - The UI enum to toggle
## @note: Brings UI to front when showing, manages focus automatically
func toggle_ui(ui: UIEnums.UI) -> void:
	# If it isn't in our ui_list any more, re‑instance it
	if not ui_list.has(ui):
		_on_add_ui_scene(ui)
		# _on_add_ui_scene handles visibility and making it current
		return

	var ui_to_toggle: Control = ui_list[ui]
	if not is_instance_valid(ui_to_toggle):
		push_warning("Instance for UI ", UIEnums.ui_to_string(ui), " invalid in toggle_ui. Re-adding.")
		ui_list.erase(ui)
		_on_add_ui_scene(ui)
		return

	var becoming_visible: bool = not ui_to_toggle.visible

	# Store mouse mode only if this action will make the *first* UI visible
	if becoming_visible and not _is_any_visible():
		previous_mouse_mode = Input.mouse_mode

	if becoming_visible:
		# If showing this UI, and it's not already current, update references
		if current_ui != ui_to_toggle:
			if is_instance_valid(current_ui):
				current_ui.visible = false # Hide the previously current UI
			swap_ui(current_ui, ui_to_toggle)
		ui_to_toggle.visible = true
		move_child(ui_to_toggle, get_child_count() - 1) # Bring to front
	else:
		# If hiding this UI
		ui_to_toggle.visible = false
		# If the UI being hidden *is* the current UI
		if current_ui == ui_to_toggle:
			# Try to make the previous UI current and visible
			var next_ui: Control = null
			if is_instance_valid(previous_ui):
				next_ui = previous_ui
				next_ui.visible = true
				move_child(next_ui, get_child_count() - 1)
			swap_ui(current_ui, next_ui) # next_ui (or null) becomes current

	# Update pause state if toggling the pause menu
	if ui == UIEnums.UI.PAUSE_MENU:
		paused = ui_to_toggle.visible

	# Update mouse mode based on whether any UI is now visible
	_handle_mouse_mode(_is_any_visible())


## Handles the "pause" action, typically opening/closing the pause menu.
##
## @note: Manages pause state, UI visibility, and mouse mode.
func _handle_pause_action() -> void:
	# Special case: Never pause from main menu
	var main_menu: Control = ui_list.get(UIEnums.UI.MAIN_MENU)
	if main_menu and is_instance_valid(main_menu) and current_ui == main_menu:
		return

	var pause_menu_enum: UIEnums.UI = UIEnums.UI.PAUSE_MENU

	# Ensure pause menu is loaded if not present
	if not ui_list.has(pause_menu_enum):
		# Store mouse mode before potentially showing the first UI
		if not _is_any_visible():
			previous_mouse_mode = Input.mouse_mode
		_on_add_ui_scene(pause_menu_enum)
		# _on_add_ui_scene should make it visible and current
		paused = true # Ensure game is paused
		# Mouse mode handled by _on_add_ui_scene's visibility change logic
		return

	var pause_menu: Control = ui_list.get(pause_menu_enum)
	if not is_instance_valid(pause_menu):
		push_error("Pause menu instance is invalid even after check/add.")
		return

	# Store mouse mode if no UI is currently visible before we show one
	if not pause_menu.visible and not _is_any_visible():
		previous_mouse_mode = Input.mouse_mode

	if current_ui == pause_menu: # Pause menu is currently active
		# Toggle pause menu visibility
		pause_menu.visible = not pause_menu.visible
		paused = pause_menu.visible # Update game pause state

		if not pause_menu.visible: # If pause menu was just hidden
			var next_ui: Control = null
			if is_instance_valid(previous_ui):
				# Restore the previous UI if it exists
				next_ui = previous_ui
				next_ui.visible = true
				move_child(next_ui, get_child_count() - 1)
			swap_ui(pause_menu, next_ui) # Previous (or null) becomes current
		# If pause menu was just shown, swap_ui isn't needed (it's already current)

	elif is_instance_valid(current_ui) and current_ui.visible: # Another UI is active
		# Hide the current UI
		current_ui.visible = false
		# Show the pause menu
		pause_menu.visible = true
		move_child(pause_menu, get_child_count() - 1) # Bring pause menu to front
		paused = true # Pause the game
		swap_ui(current_ui, pause_menu) # Pause menu becomes current

	else: # No UI is currently active/visible
		# Show the pause menu
		pause_menu.visible = true
		move_child(pause_menu, get_child_count() - 1) # Bring pause menu to front
		paused = true # Pause the game
		# No need to swap if current_ui was null, just set it
		swap_ui(current_ui, pause_menu) # Handles setting current_ui, previous becomes old current (null)

	# Update mouse mode based on whether any UI is now visible
	_handle_mouse_mode(_is_any_visible())


## Handles the "ui_cancel" action, typically closing the current UI.
##
## @note: Manages UI visibility and mouse mode, unpauses if closing pause menu.
func _handle_ui_cancel_action() -> void:
	# Special case: Never close main menu this way
	var main_menu: Control = ui_list.get(UIEnums.UI.MAIN_MENU)
	if main_menu and is_instance_valid(main_menu) and current_ui == main_menu:
		return

	if is_instance_valid(current_ui) and current_ui.visible:
		var ui_to_hide: Control = current_ui
		var ui_to_hide_enum: Variant = ui_list.find_key(ui_to_hide) # Get enum for pause check
		var was_pause_menu: bool = (ui_to_hide_enum == UIEnums.UI.PAUSE_MENU)

		ui_to_hide.visible = false # Hide the current UI

		var next_ui: Control = null
		if is_instance_valid(previous_ui):
			next_ui = previous_ui
			next_ui.visible = true # Show the previous UI
			move_child(next_ui, get_child_count() - 1) # Bring it to front

		# Update current/previous references
		swap_ui(ui_to_hide, next_ui) # next_ui (or null) becomes current

		# Update pause state ONLY if the UI being hidden was the pause menu
		if was_pause_menu:
			paused = false # Unpause the game

		# Update mouse mode based on whether any UI is now visible
		_handle_mouse_mode(_is_any_visible())

	# If no UI is currently visible, ui_cancel does nothing.


func _handle_mouse_mode(value: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else previous_mouse_mode


func _is_any_visible() -> bool:
	# Create a copy of the keys to iterate over. This allows safely removing items from the original dictionary.
	var keys_to_check: Array = ui_list.keys()
	for ui_enum in keys_to_check:
		# Check if the key still exists in the dictionary (it might have been removed).
		if not ui_list.has(ui_enum):
			continue

		# Exception for player hud - HUD visibility doesn't affect mouse mode or pausing logic here
		if ui_enum == UIEnums.UI.PLAYER_HUD:
			continue

		var node: Control = ui_list[ui_enum]

		# Check if the node instance is valid before accessing it
		if not is_instance_valid(node):
			# This state indicates a potential bug elsewhere: a UI node was freed
			push_warning(
				"Found freed instance in ui_list for key: ",
				UIEnums.ui_to_string(ui_enum),
				". This might indicate the UI was freed externally or remove_ui failed. Removing stale entry."
			)
			# Clean up the stale entry to prevent future errors
			ui_list.erase(ui_enum)
			# Skip to the next key
			continue

		# If the node is valid and visible, return true
		if node.visible:
			return true

	# If the loop finishes without finding any other visible UI
	return false


## Completely switches to a new UI scene
##
## @param: new_ui - The UI enum to switch to
## @param: params - Optional parameters to pass to the new UI
func _on_switch_ui(new_ui: UIEnums.UI, params: Dictionary = {}) -> void:
	clear_ui() # Clears everything including pause state and mouse mode

	# Load the new UI scene from the path
	_on_add_ui_scene(new_ui, params)


## Adds and initializes a new UI scene
##
## @param: new_ui - The UI enum to add
## @param: params - Dictionary of initialization parameters
func _on_add_ui_scene(new_ui: UIEnums.UI, params: Dictionary = {}) -> void:
	# Avoid adding if it already exists and is valid
	if ui_list.has(new_ui) and is_instance_valid(ui_list[new_ui]):
		# If it exists but isn't current, make it current
		var existing_node: Control = ui_list[new_ui]
		if current_ui != existing_node:
			if not existing_node.visible and not _is_any_visible():
				previous_mouse_mode = Input.mouse_mode # Store if first visible
			if is_instance_valid(current_ui):
				current_ui.visible = false
			swap_ui(current_ui, existing_node)
			current_ui.visible = true
			move_child(current_ui, get_child_count() - 1)
			_handle_mouse_mode(true)
		return # Don't re-add

	# Load the UI scene from the path
	var new_ui_path: String = UIEnums.PATHS.get(new_ui, "")
	if new_ui_path.is_empty():
		push_error("Error: No path defined for UI enum: ", new_ui)
		return

	var new_ui_resource: Resource = ResourceLoader.load(new_ui_path)

	# Exit if the scene failed to load
	if not new_ui_resource:
		push_error("Error: Could not load UI scene at path: ", new_ui_path)
		return

	# Check if the loaded resource is a PackedScene
	if not new_ui_resource is PackedScene:
		push_error("Error: Resource at path is not a PackedScene: ", new_ui_path)
		return

	# Instantiate the new UI scene
	var new_ui_node: Control = new_ui_resource.instantiate()
	if not new_ui_node is Control:
		push_error("Error: Instantiated scene root is not a Control node: ", new_ui_path)
		if is_instance_valid(new_ui_node): new_ui_node.queue_free() # Clean up invalid instance
		return

	# Stores the mouse mode if UI scene will be visible and no others are
	if new_ui_node.visible and not _is_any_visible():
		previous_mouse_mode = Input.mouse_mode

	# If the UI has a setup or initialize method, call it with parameters
	if new_ui_node.has_method("setup"):
		new_ui_node.setup(params)

	# hook up the exit tree and visibility
	# Use Callable.bind() to pass the node itself to the signal handler if needed
	new_ui_node.tree_exited.connect(
		func(): SignalManager.ui_disabled.emit() # Consider passing which UI exited
	)
	new_ui_node.visibility_changed.connect(
		func():
			if not new_ui_node.visible:
				SignalManager.ui_disabled.emit() # Consider passing which UI was hidden
	)

	# Add it as a child of the UI manager
	add_child(new_ui_node)

	# Hide the previously current UI if one exists and is valid
	if is_instance_valid(current_ui):
		current_ui.visible = false

	# Make the new UI current
	swap_ui(current_ui, new_ui_node)
	ui_list[new_ui] = new_ui_node

	# Ensure the new UI is visible and on top
	current_ui.visible = true
	move_child(current_ui, get_child_count() - 1)

	# Update mouse mode based on the new UI's visibility
	_handle_mouse_mode(current_ui.visible)

	# Special handling if adding the pause menu - ensure game pause state matches
	if new_ui == UIEnums.UI.PAUSE_MENU:
		paused = current_ui.visible
