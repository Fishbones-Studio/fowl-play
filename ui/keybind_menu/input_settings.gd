## Script to display and manage input settings in a UI
##
## This script handles the input settings UI, allowing users to remap keys and save their preferences
extends Control

@onready var input_button_scene: PackedScene = preload("uid://c742rhgrg2wc2") ## scene for the clickable button row
@onready var action_list: GridContainer = %ActionList ## container for the clickable button rows

var config_path: String = "user://keybinds.cfg" ## path to the config file, on windows saved at C:\Users\<user>\AppData\Roaming\Godot\app_userdata\fowl-play\keybinds.cfg
var config_name: String = "keybinds" ## name of the config section, mostly useful when multiple segments are used in the same file


func _ready():
	# Initial load of saved settings when scene enters tree
	_load_input_settings()


func _input(event: InputEvent) -> void:
	if not SaveManager.is_remapping:
		return

	var input_type = SaveManager.input_type
	var action     = SaveManager.action_to_remap

	# Validate event type matches input mode (keyboard/mouse vs controller)
	if not _is_valid_event_for_input_type(event, input_type):
		return

	# Prevent double-click from being registered as valid input
	if event is InputEventMouseButton and event.double_click:
		event = event.duplicate()
		event.double_click = false

	# Check for existing assignments to prevent key conflict
	if _is_event_already_assigned(event, action):
		print("Input event already assigned to another action")
		return

	var current_events: Array[InputEvent] = InputMap.action_get_events(action)
	var split_events: Dictionary          = _split_events_by_type(current_events)

	# Replace existing binding of same type (primary/secondary/controller)
	var old_event: InputEvent = _get_event_to_replace(split_events, input_type)
	if old_event:
		InputMap.action_erase_event(action, old_event)

	InputMap.action_add_event(action, event)
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

	if config.load(config_path) == OK:
		# Replace default bindings with user's saved preferences
		for action in config.get_section_keys(config_name):
			InputMap.action_erase_events(action)
			for event in config.get_value(config_name, action):
				InputMap.action_add_event(action, event)

	_create_action_list()


func _create_action_list():
	# Clear existing UI elements before rebuilding
	for child in action_list.get_children():
		child.queue_free()

	# Create row for each customizable action
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue  # Skip built-in UI actions

		var action_row: Node         = input_button_scene.instantiate()
		var split_events: Dictionary = _split_events_by_type(InputMap.action_get_events(action))

		action_row.find_child("ActionLabel").text = action
		_set_label_text(action_row, "PrimaryInputLabel", split_events.primary)
		_set_label_text(action_row, "SecondaryInputLabel", split_events.secondary)
		_set_label_text(action_row, "ControllerInputLabel", split_events.controller)

		action_list.add_child(action_row)


func _trim_mapping_suffix(mapping: String) -> String:
	# Clean up display text by removing technical suffixes
	var cleaned: String = mapping.replace(" (Physical)", "")

	# Simplify controller input formatting
	if cleaned.begins_with("Joypad"):
		var start: int = cleaned.find("(")
		var end: int   = cleaned.find(")")
		if start != -1 and end != -1:
			# Extract button name from parentheses
			cleaned = cleaned.substr(start + 1, end - start - 1)
		else:
			# Fallback to first word before space
			cleaned = cleaned.substr(0, cleaned.find(" "))

	return cleaned.strip_edges()


func _on_back_button_pressed():
	# Clean up state and persist changes
	SaveManager.is_remapping = false
	_save_input_settings()
	queue_free()


func _on_reset_button_pressed():
	# Restore default bindings and remove config file
	InputMap.load_from_project_settings()

	if FileAccess.file_exists(config_path):
		DirAccess.remove_absolute(config_path)

	_create_action_list()


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
	# Check all actions except current one for duplicate bindings
	for action in InputMap.get_actions():
		if action == current_action:
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


func _set_label_text(row: MarginContainer, label_name: String, event: InputEvent):
	# Helper to safely set text on labels with fallback
	var label: Node = row.find_child(label_name)
	if event:
		label.text = _trim_mapping_suffix(event.as_text())
	else:
		label.text = "Unassigned"
