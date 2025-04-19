## UI manager
## This script manages the UI scenes in the game.
## It handles switching between different UI scenes and loading them dynamically.
extends CanvasLayer

var current_ui: Control
var previous_ui: Control
var previous_mouse_mode: Input.MouseMode
var ui_list: Dictionary[UIEnums.UI, Control]

var paused:
	set(value):
		paused = value
		get_tree().paused = value
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else previous_mouse_mode


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	SignalManager.switch_ui_scene.connect(_on_switch_ui)
	SignalManager.add_ui_scene.connect(_on_add_ui_scene)

	# Intial UI
	_on_add_ui_scene(UIEnums.UI.MAIN_MENU)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		handle_pause()


func clear_ui() -> void:
	for ui in ui_list:
		ui_list[ui].visible = false

	for child in get_children():
		remove_child(child)
		child.queue_free()

	ui_list.clear()

	previous_ui = null
	current_ui = null


func swap_ui(prev_ui: Control, curr_ui: Control) -> void:
	previous_ui = prev_ui if is_instance_valid(prev_ui) else null
	current_ui = curr_ui if is_instance_valid(curr_ui) else null


func toggle_ui(ui: UIEnums.UI) -> void:
	if ui not in ui_list:
		push_error("'", UIEnums.ui_to_string(ui), "'", " does not exist in the list.")
		return

	var ui_to_show: Control = ui_list[ui]

	if current_ui != ui_to_show:
		swap_ui(current_ui, ui_to_show)

	ui_to_show.visible = not ui_to_show.visible

	move_child(ui_to_show, get_child_count() - 1)


func handle_pause() -> void:
	# TODO: Test settings
	var main_menu: Control = ui_list.get(UIEnums.UI.MAIN_MENU)
	if  main_menu and current_ui == main_menu:
		return

	if not paused:
		previous_mouse_mode = Input.mouse_mode

	var pause_menu: Control = ui_list.get(UIEnums.UI.PAUSE_MENU)
	var pause_menu_visible: bool = pause_menu and pause_menu.visible
	var is_current_pause_menu: bool = current_ui == pause_menu

	if is_current_pause_menu:
		current_ui.visible = not current_ui.visible
		paused = current_ui.visible
	elif current_ui:
		current_ui.visible = false
		paused = pause_menu_visible
		swap_ui(current_ui, previous_ui)


func _on_switch_ui(new_ui: UIEnums.UI, params: Dictionary = {}) -> void:
	clear_ui()

	# Load the new UI scene from the path
	_on_add_ui_scene(new_ui, params)


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
