################################################################################
## Manages all UI scenes in the game, handling dynamic loading, switching,
## and visibility. Also provides pause functionality and input management
## for UI elements.
################################################################################
extends CanvasLayer

var current_ui: Control # Currently active UI control
var previous_ui: Control # Previously active UI control (for navigation history)
# Stores the mouse mode before UI changes (for proper restoration)
var previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED # Default to captured
# Dictionary mapping UI enums to their instantiated Control nodes
var ui_list: Dictionary[UIEnums.UI, Control] = {}

# Pause state with setter that manages game pause
var paused := false:
	set(value):
		# Prevent setting pause state if it's already the target value
		if paused == value:
			return
		paused = value
		get_tree().paused = value


func _ready() -> void:
	# Ensure UI manager processes even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	SignalManager.switch_ui_scene.connect(_on_switch_ui)
	SignalManager.add_ui_scene.connect(_on_add_ui_scene)

	# Initialize with main menu (or potentially nothing, depending on game start)
	# If the game starts directly in-game, you might add the HUD here instead
	# or wait for a signal. Let's keep the Main Menu for now as per original.
	_on_add_ui_scene(UIEnums.UI.MAIN_MENU)


func _input(_event: InputEvent) -> void:
	# Handle pause input globally
	if Input.is_action_just_pressed("pause"):
		handle_pause()

	
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
		# It might have already been removed or freed elsewhere
		push_warning("Attempted to remove UI '", ui.name if is_instance_valid(ui) else "INVALID", "' not found in ui_list or invalid.")
		# Clean up potential dangling key if node is invalid but key exists
		var key_to_remove = ui_list.find_key(ui)
		if key_to_remove != null:
			ui_list.erase(key_to_remove)
		return

	var ui_enum: UIEnums.UI = ui_list.find_key(ui)

	# Handle references before removing
	if current_ui == ui:
		# If removing the current UI, try to revert to the previous one
		current_ui = previous_ui if is_instance_valid(previous_ui) else null
		previous_ui = null # Clear previous since we just reverted to it
		if is_instance_valid(current_ui):
			current_ui.visible = true # Make the new current UI visible
			move_child(current_ui, get_child_count() - 1) # Bring to front
	elif previous_ui == ui:
		previous_ui = null

	# Remove from scene tree and dictionary
	if ui.get_parent() == self:
		remove_child(ui)
	ui.queue_free()
	ui_list.erase(ui_enum)

	# Update pause state and mouse mode if necessary
	# If the pause menu was removed while active, unpause
	if ui_enum == UIEnums.UI.PAUSE_MENU and paused:
		paused = false

	# Update mouse mode based on remaining visible UI
	_handle_mouse_mode(_is_any_visible())


## Clears all UI elements from the manager
##
## @note: Completely resets the UI state, removing all controls from the manager
func clear_ui() -> void:
	# Remove and free all managed UI children
	# Iterate over a copy because removing children modifies the array
	for child in get_children().duplicate():
		# Ensure we only remove Controls managed by this script
		if child is Control and ui_list.values().has(child):
			var ui_enum = ui_list.find_key(child)
			if ui_enum != null: # Check if find_key was successful
				ui_list.erase(ui_enum)
			remove_child(child)
			child.queue_free()

	# Reset state variables
	ui_list.clear() # Ensure list is empty
	previous_ui = null
	current_ui = null
	paused = false # Unpause the game
	# Restore default mouse mode (likely captured for gameplay)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	previous_mouse_mode = Input.MOUSE_MODE_CAPTURED


## Swaps the current and previous UI references
##
## @param: prev_ui - The UI control being replaced
## @param: curr_ui - The new UI control to make current
## @note: Handles null/invalid instances safely
func swap_ui(prev_ui: Control, curr_ui: Control) -> void:
	previous_ui = prev_ui if is_instance_valid(prev_ui) else null
	current_ui = curr_ui if is_instance_valid(curr_ui) else null


## Toggles visibility of a specific UI
## Use this for overlays like Inventory, Map, etc., not for Pause or main switching.
##
## @param: ui_enum - The UI enum to toggle
## @note: Brings UI to front when showing, manages focus automatically
func toggle_ui(ui_enum: UIEnums.UI) -> void:
	# Pause menu should be handled by handle_pause()
	if ui_enum == UIEnums.UI.PAUSE_MENU:
		push_warning("Use handle_pause() to toggle the pause menu, not toggle_ui().")
		handle_pause() # Redirect to the correct function
		return

	# Add the UI if it doesn't exist yet
	if not ui_list.has(ui_enum):
		_on_add_ui_scene(ui_enum) # Add it (will become current)
		# _on_add_ui_scene handles visibility and mouse mode
		return

	var ui_to_toggle: Control = ui_list.get(ui_enum)
	if not is_instance_valid(ui_to_toggle):
		push_error("UI node for ", UIEnums.ui_to_string(ui_enum), " is invalid.")
		ui_list.erase(ui_enum) # Clean up invalid entry
		return

	var becoming_visible: bool = not ui_to_toggle.visible

	if becoming_visible:
		# If another UI is currently active, hide it and set it as previous
		if is_instance_valid(current_ui) and current_ui != ui_to_toggle:
			current_ui.visible = false
			swap_ui(current_ui, ui_to_toggle)
		# If no UI was visible, set current directly
		elif not is_instance_valid(current_ui):
			swap_ui(null, ui_to_toggle)

		# Save mouse mode only when the *first* UI becomes visible
		if not _is_any_visible():
			previous_mouse_mode = Input.mouse_mode

		ui_to_toggle.visible = true
		move_child(ui_to_toggle, get_child_count() - 1) # Bring to front
	else:
		# Hiding the UI
		ui_to_toggle.visible = false
		# If we hid the current UI, try to revert to the previous one
		if current_ui == ui_to_toggle:
			var next_ui = previous_ui if is_instance_valid(previous_ui) else null
			swap_ui(current_ui, next_ui) # current becomes previous, next becomes current
			if is_instance_valid(current_ui):
				current_ui.visible = true # Show the new current UI
				move_child(current_ui, get_child_count() - 1) # Bring to front

	# Update mouse mode based on whether *any* UI (except HUD) is now visible
	_handle_mouse_mode(_is_any_visible())


## Handles pause state and UI visibility changes
##
## @note: Manages the complex interplay between pause menu and other UIs
func handle_pause() -> void:
	# Special case: Never pause from main menu
	var main_menu: Control = ui_list.get(UIEnums.UI.MAIN_MENU)
	if is_instance_valid(main_menu) and current_ui == main_menu and main_menu.visible:
		return

	# Get or add the pause menu instance
	var pause_menu: Control = ui_list.get(UIEnums.UI.PAUSE_MENU)
	if not is_instance_valid(pause_menu):
		_on_add_ui_scene(UIEnums.UI.PAUSE_MENU, {}, false) # Add but keep hidden initially
		pause_menu = ui_list.get(UIEnums.UI.PAUSE_MENU)
		if not is_instance_valid(pause_menu):
			push_error("Failed to instantiate Pause Menu!")
			return

	# Determine if we are pausing or unpausing
	var is_pausing: bool = not paused # If game isn't paused, we intend to pause

	if is_pausing:
		# Save mouse mode only when the first UI (pause menu) becomes visible
		if not _is_any_visible():
			previous_mouse_mode = Input.mouse_mode

		# Hide the current UI (if any and if it's not the pause menu itself)
		if is_instance_valid(current_ui) and current_ui != pause_menu:
			current_ui.visible = false
			# Set the hidden UI as the previous one, so we can return to it
			swap_ui(current_ui, pause_menu)
		elif not is_instance_valid(current_ui):
			# If no UI was active, just set pause menu as current
			swap_ui(null, pause_menu)

		# Show and activate pause menu
		pause_menu.visible = true
		move_child(pause_menu, get_child_count() - 1)
		paused = true
		_handle_mouse_mode(true) # Show mouse cursor
	else:
		# Unpausing
		pause_menu.visible = false
		paused = false

		# Restore the previous UI (if any)
		var ui_to_restore = previous_ui if is_instance_valid(previous_ui) else null
		swap_ui(pause_menu, ui_to_restore) # current becomes pause_menu, previous becomes current

		if is_instance_valid(current_ui):
			current_ui.visible = true # Show the restored UI
			move_child(current_ui, get_child_count() - 1)

		# Restore mouse mode based on whether any UI remains visible
		_handle_mouse_mode(_is_any_visible())


## Sets the mouse mode based on UI visibility
func _handle_mouse_mode(ui_visible: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if ui_visible else previous_mouse_mode


## Checks if any UI (excluding Player HUD) is currently visible
func _is_any_visible() -> bool:
	for ui_enum in ui_list:
		# Skip the Player HUD as it doesn't block interaction
		if ui_enum == UIEnums.UI.PLAYER_HUD:
			continue

		var node = ui_list[ui_enum]
		# Check validity before accessing properties
		if is_instance_valid(node) and node.visible:
			return true # Found a visible UI

	return false # No visible UI found (besides potentially the HUD)


## Completely switches to a new UI scene (e.g., Main Menu -> Game HUD)
##
## @param: new_ui_enum - The UI enum to switch to
## @param: params - Optional parameters to pass to the new UI's setup method
func _on_switch_ui(new_ui_enum: UIEnums.UI, params: Dictionary = {}) -> void:
	clear_ui() # Remove all existing UIs first
	_on_add_ui_scene(new_ui_enum, params) # Add the new one


## Adds and initializes a new UI scene instance.
## Assumes the new UI should be visible unless specified otherwise.
##
## @param: new_ui_enum - The UI enum to add
## @param: params - Dictionary of initialization parameters for setup method
## @param: make_visible - Should the UI be immediately visible? (Defaults true)
func _on_add_ui_scene(new_ui_enum: UIEnums.UI, params: Dictionary = {}, make_visible: bool = true) -> void:
	# Prevent adding duplicates if an instance already exists and is valid
	if ui_list.has(new_ui_enum) and is_instance_valid(ui_list[new_ui_enum]):
		push_warning("Attempted to add UI '", UIEnums.ui_to_string(new_ui_enum), "' which already exists.")
		# Optionally, make the existing one visible if requested
		if make_visible and not ui_list[new_ui_enum].visible:
			toggle_ui(new_ui_enum) # Use toggle to handle state correctly
		return

	# Load the UI scene resource
	var new_ui_path: String = UIEnums.PATHS.get(new_ui_enum, "")
	if new_ui_path.is_empty():
		push_error("Error: No path defined for UI enum: ", UIEnums.ui_to_string(new_ui_enum))
		return
	var new_ui_resource: Resource = ResourceLoader.load(new_ui_path)

	# Validate the loaded resource
	if not new_ui_resource:
		push_error("Error: Could not load UI scene at path: ", new_ui_path)
		return
	if not new_ui_resource is PackedScene:
		push_error("Error: Resource at path is not a PackedScene: ", new_ui_path)
		return

	# Instantiate the new UI scene
	var new_ui_node: Node = new_ui_resource.instantiate()
	if not new_ui_node is Control:
		push_error("Error: Instantiated scene root is not a Control node: ", new_ui_path)
		if is_instance_valid(new_ui_node):
			new_ui_node.queue_free() # Clean up invalid instance
		return

	# Call setup method if it exists
	if new_ui_node.has_method("setup"):
		new_ui_node.setup(params)

	# Add the node to the scene tree and the manager list
	add_child(new_ui_node)
	ui_list[new_ui_enum] = new_ui_node

	# Handle visibility and state
	if make_visible:
		# Save mouse mode if this is the first UI becoming visible
		if not _is_any_visible():
			previous_mouse_mode = Input.mouse_mode

		# If another UI is active, hide it and set it as previous
		if is_instance_valid(current_ui):
			current_ui.visible = false
		swap_ui(current_ui, new_ui_node) # New node becomes current

		new_ui_node.visible = true
		move_child(new_ui_node, get_child_count() - 1) # Bring to front
		_handle_mouse_mode(true) # Show mouse
	else:
		# If added but not made visible (like initially adding Pause Menu)
		new_ui_node.visible = false
		# Don't change current_ui or mouse mode
