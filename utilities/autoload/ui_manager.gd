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
var ui_list: Dictionary[UIEnums.UI, Control]

# Pause state with setter that manages game pause and mouse visibility
var paused:
	set(value):
		paused = value
		get_tree().paused = value
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else previous_mouse_mode


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
		handle_pause()


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
	ui_list.erase(ui_enum)

	# Update pause state
	handle_pause()


## Clears all UI elements from the manager
##
## @note: Completely resets the UI state, removing all controls from the manager
func clear_ui() -> void:
	# Hide all ui nodes
	for ui in ui_list:
		ui_list[ui].visible = false

	# Remove and free all child from scene tree
	for child in get_children():
		remove_child(child)
		child.queue_free()

	ui_list.clear()

	# Reset state
	previous_ui = null
	current_ui = null


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
	if ui not in ui_list:
		push_error("'", UIEnums.ui_to_string(ui), "'", " does not exist in the list.")
		return

	var ui_to_show: Control = ui_list[ui]

	if current_ui != ui_to_show:
		swap_ui(current_ui, ui_to_show)


	current_ui.visible = not current_ui.visible

	move_child(ui_to_show, get_child_count() - 1)


## Handles pause state and UI visibility changes
##
## @note: Manages the complex interplay between pause menu and other UIs
func handle_pause() -> void:
	# TODO: Test settings

	# Special case: Never pause from main menu
	var main_menu: Control = ui_list.get(UIEnums.UI.MAIN_MENU)
	if  main_menu and current_ui == main_menu:
		return

	# Store current mouse mode when first pausing
	if not paused:
		previous_mouse_mode = Input.mouse_mode

	var pause_menu: Control = ui_list.get(UIEnums.UI.PAUSE_MENU)
	var pause_menu_visible: bool = pause_menu and pause_menu.visible
	var is_current_pause_menu: bool = current_ui == pause_menu

	# Handle pause menu toggle
	if is_current_pause_menu:
		current_ui.visible = not current_ui.visible
		paused = current_ui.visible

	# Hide current UI when pausing from elsewhere
	elif current_ui:
		current_ui.visible = false
		paused = pause_menu_visible
		swap_ui(current_ui, previous_ui)

	# Fallback case for restoring from pause
	elif previous_ui: 
		swap_ui(ui_list[UIEnums.UI.PAUSE_MENU], previous_ui)
		paused = current_ui.visible


## Completely switches to a new UI scene
##
## @param: new_ui - The UI enum to switch to
## @param: params - Optional parameters to pass to the new UI
func _on_switch_ui(new_ui: UIEnums.UI, params: Dictionary = {}) -> void:
	clear_ui()

	# Load the new UI scene from the path
	_on_add_ui_scene(new_ui, params)


## Adds and initializes a new UI scene
##
## @param: new_ui - The UI enum to add
## @param: params - Dictionary of initialization parameters
func _on_add_ui_scene(new_ui: UIEnums.UI, params: Dictionary = {}) -> void:
	# Load the UI scene from the path
	var new_ui_path: String = UIEnums.PATHS[new_ui]
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

	# If the UI has a setup or initialize method, call it with parameters
	if new_ui_node.has_method("setup") and params:
		new_ui_node.setup(params)

	# Add it as a child of the UI manager
	add_child(new_ui_node)
	swap_ui(current_ui, new_ui_node)

	ui_list[new_ui] = new_ui_node
