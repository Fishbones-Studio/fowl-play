################################################################################
## Script to display and manage input settings in a UI.
##
## This script handles the input settings UI, allowing users to remap keys and 
## save their preferences. Includes full controller support using ui_* actions.
################################################################################
extends Control

var config_path: String = "user://settings.cfg" ## path to the config file, on windows saved at C:\Users\<user>\AppData\Roaming\Godot\app_userdata\fowl-play\keybinds.cfg
var config_name: String = "keybinds" ## name of the config section, mostly useful when multiple segments are used in the same file

@onready var stylebox_focus: StyleBoxFlat = load("uid://dwicgkvjluob0")
@onready var input_button_scene: PackedScene = preload("uid://bpba8wvtfww4x")
@onready var error_text_label: Label = %ErrorTextLabel
@onready var restore_defaults_button: Button = %RestoreDefaultsButton
@onready var content_container: VBoxContainer = %ContentContainer

# Navigation focus tracking
var _current_focus_index: int = 0
var _focusable_buttons: Array[Button] = []


func _ready():
	# Make this block input to lower layers
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	self.focus_mode = Control.FOCUS_ALL

	# Initial load of saved settings when scene enters tree
	_load_input_settings()


func _input(event: InputEvent) -> void:
	if SaveManager.is_remapping:
		if event is InputEventMouseMotion:
			return

		get_viewport().set_input_as_handled()

		# Validate event type matches input mode
		if not _is_valid_event_for_input_type(event, SaveManager.input_type):
			error_text_label.text = "Invalid input event for this action"
			return

		# Prevent double-click from being registered
		if event is InputEventMouseButton and event.double_click:
			event = event.duplicate()
			event.double_click = false

		# Check for existing assignments
		if _is_event_already_assigned(event, SaveManager.action_to_remap):
			error_text_label.text = "Input event already assigned to another action"
			return

		var current_events: Array[InputEvent] = InputMap.action_get_events(SaveManager.action_to_remap)
		var split_events: Dictionary = _split_events_by_type(current_events)

		# Replace existing binding of same type
		var old_event: InputEvent = _get_event_to_replace(split_events, SaveManager.input_type)
		if old_event:
			InputMap.action_erase_event(SaveManager.action_to_remap, old_event)

		InputMap.action_add_event(SaveManager.action_to_remap, event)
		_finalize_remapping()
	else:

		if Input.is_action_just_pressed("ui_accept"):
			_activate_focused_button()


func _save_input_settings():
	var config = ConfigFile.new()

	# Skip Godot's built-in UI actions to prevent accidental override
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue

		config.set_value(config_name, action, InputMap.action_get_events(action))

	config.save(config_path)


func _load_input_settings():
	# Load defaults first, then override with saved config
	InputMap.load_from_project_settings()

	SaveManager.load_settings(config_name)

	_create_action_list()


func _create_action_list():
	error_text_label.text = ""

	# Clear existing children
	for child in content_container.get_children():
		child.queue_free()

	# Add action rows
	for action in InputMap.get_actions():
		if action.begins_with("ui_") or action in ["cycle_debug_menu", "toggle_console"]:
			continue

		var action_row: Node = input_button_scene.instantiate()
		var split_events: Dictionary = _split_events_by_type(InputMap.action_get_events(action))

		action_row.find_child("Label").text = action
		_set_label_text(action_row, "PrimaryPanel", split_events.primary, action)
		_set_label_text(action_row, "SecondaryPanel", split_events.secondary, action)
		_set_label_text(action_row, "ControllerPanel", split_events.controller, action)

		content_container.add_child(action_row)

	# Setup navigation after creating UI
	_setup_navigation()


func _setup_navigation():
	_focusable_buttons.clear()
	var grid: Array = _get_button_grid()

	# Flatten grid into focusable buttons array (row-major order)
	for row in grid:
		_focusable_buttons.append_array(row)

	# Set initial focus
	if _focusable_buttons.size() > 0:
		_current_focus_index = 0
		_focusable_buttons[_current_focus_index].grab_focus()


func _get_button_grid() -> Array:
	var grid: Array = []

	# Build grid of remap buttons per row
	for row in content_container.get_children():
		var row_buttons: Array[Button] = []
		for panel_name in ["PrimaryPanel", "SecondaryPanel", "ControllerPanel"]:
			var panel := row.find_child(panel_name) as RemapPanel
			if panel and panel.button is Button:
				panel.button.focus_mode = Control.FOCUS_ALL
				row_buttons.append(panel.button)
		if row_buttons.size() > 0:
			grid.append(row_buttons)

	# Add restore defaults button as its own row
	if restore_defaults_button is Button:
		restore_defaults_button.focus_mode = Control.FOCUS_ALL
		grid.append([restore_defaults_button])

	return grid


func _activate_focused_button():
	var focused := get_viewport().gui_get_focus_owner() as Button
	if focused:
		focused.emit_signal("pressed")


func _trim_mapping_suffix(mapping: String) -> String:
	# Clean up display text by removing technical suffixes
	var cleaned: String = mapping.replace(" (Physical)", "")

	# Simplify controller input formatting
	if cleaned.begins_with("Joypad"):
		var start: int = cleaned.find("(")
		var end: int = cleaned.find(")")
		if start != -1 and end != -1:
			# Extract button name from parentheses
			cleaned = cleaned.substr(start + 1, end - start - 1)
		else:
			# Fallback to first word before space
			cleaned = cleaned.substr(0, cleaned.find(" "))

	return cleaned.strip_edges()


func _is_valid_event_for_input_type(event: InputEvent, input_type: int) -> bool:
	# Validate controller vs keyboard/mouse input based on remap mode
	match input_type:
		SaveEnums.InputType.CONTROLLER:
			return event is InputEventJoypadButton or event is InputEventJoypadMotion
		_: # Only controller is special, Primary and Secondary can be treated the same
			return event is InputEventMouseButton or event is InputEventKey


func _split_events_by_type(events: Array[InputEvent]) -> Dictionary:
	# Categorize inputs by type with priority: primary > secondary > controller
	var result: Dictionary = {
								 primary = null,
								 secondary = null,
								 controller = null
							 }

	for event in events:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if not result.controller:
				result.controller = event
		else:
			# Fill primary first, then secondary
			if not result.primary:
				result.primary = event
			elif not result.secondary:
				result.secondary = event

	return result


func _is_event_already_assigned(event: InputEvent, current_action: String) -> bool:
	# Check all actions except current one for duplicate bindings. Also ignore built-in UI actions
	for action in InputMap.get_actions():
		if action == current_action or action.begins_with("ui_") or action in ["cycle_debug_menu", "toggle_console"]:
			continue

		for existing_event in InputMap.action_get_events(action):
			if existing_event.is_match(event):
				return true

	return false


func _get_event_to_replace(split_events: Dictionary, input_type: int) -> InputEvent:
	# Get existing binding slot to replace based on input type
	match input_type:
		SaveEnums.InputType.PRIMARY: return split_events.primary
		SaveEnums.InputType.SECONDARY: return split_events.secondary
		SaveEnums.InputType.CONTROLLER: return split_events.controller
		_: return null


func _finalize_remapping():
	# Update storage and UI after successful remapping
	_save_input_settings()
	SaveManager.is_remapping = false
	SaveManager.action_to_remap = ""
	_create_action_list()


func _set_label_text(row: Node, container_name: String, event: InputEvent, action_to_remap: String = ""):
	# Helper to safely set text on labels with fallback
	var panel: RemapPanel = row.find_child(container_name)
	if event:
		panel.button.text = _trim_mapping_suffix(event.as_text())
	else:
		panel.button.text = "Unassigned"
	panel.action_to_remap = action_to_remap


func _on_restore_defaults_button_button_up() -> void:
	SaveManager.is_remapping = false
	SaveManager.action_to_remap = ""

	# Restore default bindings and remove config file
	InputMap.load_from_project_settings()

	if FileAccess.file_exists(config_path):
		DirAccess.remove_absolute(config_path)

	_create_action_list()

	TweenManager.create_scale_tween(null, restore_defaults_button, Vector2(1.0, 1.0))
	restore_defaults_button.add_theme_stylebox_override("focus", stylebox_focus)


func _on_restore_defaults_button_button_down() -> void:
	TweenManager.create_scale_tween(null, restore_defaults_button, Vector2(0.9, 0.9))
	restore_defaults_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
