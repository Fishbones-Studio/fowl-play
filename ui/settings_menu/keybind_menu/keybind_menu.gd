################################################################################
## Script to display and manage input settings in a UI.
##
## This script handles the input settings UI, allowing users to remap keys and 
## save their preferences.
################################################################################
extends Control

var config_path: String = "user://settings.cfg" ## path to the config file, on windows saved at C:\Users\<user>\AppData\Roaming\Godot\app_userdata\fowl-play\keybinds.cfg
var config_name: String = "keybinds" ## name of the config section, mostly useful when multiple segments are used in the same file

@onready var stylebox_focus: StyleBoxFlat = load("uid://dwicgkvjluob0")
@onready var input_button_scene: PackedScene = preload("uid://bpba8wvtfww4x") ## scene for the clickable button row
@onready var error_text_label: Label = %ErrorTextLabel
@onready var restore_defaults_button: Button = %RestoreDefaultsButton
@onready var content_container: VBoxContainer = %ContentContainer


func _unhandled_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()


func _ready():
	# Make this block input to lower layers
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	self.focus_mode = Control.FOCUS_ALL

	# Initial load of saved settings when scene enters tree
	_load_input_settings()


func _input(event: InputEvent) -> void:
	if not SaveManager.is_remapping || event is InputEventMouseMotion:
		return

	get_viewport().set_input_as_handled()

	var input_type = SaveManager.input_type
	var action_to_remap = SaveManager.action_to_remap

	# Validate event type matches input mode (keyboard/mouse vs controller)
	if not _is_valid_event_for_input_type(event, input_type):
		error_text_label.text = "Invalid input event for this action"
		return

	# Prevent double-click from being registered as valid input
	if event is InputEventMouseButton and event.double_click:
		event = event.duplicate()
		event.double_click = false

	# Check for existing assignments to prevent key conflict
	if _is_event_already_assigned(event, action_to_remap):
		error_text_label.text = "Input event already assigned to another action"
		return

	var current_events: Array[InputEvent] = InputMap.action_get_events(action_to_remap)
	var split_events: Dictionary = _split_events_by_type(current_events)

	# Replace existing binding of same type (primary/secondary/controller)
	var old_event: InputEvent = _get_event_to_replace(split_events, input_type)
	if old_event:
		InputMap.action_erase_event(action_to_remap, old_event)

	InputMap.action_add_event(action_to_remap, event)
	_finalize_remapping()


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
	var config = ConfigFile.new()

	if config.load(config_path) == OK and config.has_section(config_name):
		# Replace default bindings with user's saved preferences
		for action in config.get_section_keys(config_name):
			InputMap.action_erase_events(action)
			for event in config.get_value(config_name, action):
				InputMap.action_add_event(action, event)

	_create_action_list()


func _create_action_list():
	error_text_label.text = ""
	# Clear existing children
	for child in content_container.get_children():
		child.queue_free()

	# Add action rows
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue # Skip built-in UI actions

		var action_row: Node = input_button_scene.instantiate()
		var split_events: Dictionary = _split_events_by_type(InputMap.action_get_events(action))

		action_row.find_child("Label").text = action
		_set_label_text(action_row, "PrimaryPanel", split_events.primary, action)
		_set_label_text(action_row, "SecondaryPanel", split_events.secondary, action)
		_set_label_text(action_row, "ControllerPanel", split_events.controller, action)

		content_container.add_child(action_row)


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
		if action == current_action || action.begins_with("ui_"):
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
