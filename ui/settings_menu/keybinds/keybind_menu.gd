################################################################################
## Script to display and manage input settings in a UI.
##
## This script handles the input settings UI, allowing users to remap keys and 
## save their preferences. Includes full controller support using ui_* actions.
################################################################################
extends Control

signal back_requested

const MAX_INPUT_COUNT: int = 5

var config_path: String = "user://settings.cfg" ## path to the config file, on windows saved at C:\Users\<user>\AppData\Roaming\Godot\app_userdata\fowl-play\keybinds.cfg
var config_name: String = "keybinds" ## name of the config section, mostly useful when multiple segments are used in the same file

var _input_counter: int = 0
var _controller_connected: bool = false

@onready var input_button_resource: PackedScene = preload("uid://bpba8wvtfww4x")
@onready var content_item_icon_resource: PackedScene = preload("uid://dewuhjp8gx8cw")
@onready var error_text_label: Label = %ErrorTextLabel
@onready var restore_defaults_button: Button = %RestoreDefaultsButton
@onready var content_container: VBoxContainer = %ContentContainer


func _ready() -> void:
	# Make this block input to lower layers
	mouse_filter = Control.MOUSE_FILTER_STOP

	var joypads: Array[int] = Input.get_connected_joypads()
	_controller_connected = not joypads.is_empty()

	Input.joy_connection_changed.connect(_on_controller_changed)

	# Initial load of saved settings when scene enters tree
	_load_input_settings()


func _input(event: InputEvent) -> void:
	if SettingsManager.is_remapping:
		if event is InputEventMouseMotion:
			return

		get_viewport().set_input_as_handled()

		_input_counter += 1
		if _input_counter >= MAX_INPUT_COUNT:
			SettingsManager.is_remapping = false
			SettingsManager.action_to_remap = ""
			_create_action_list()

		# TODO: Improve for performance
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			var event_type: Dictionary = ControllerMappings.extract_joypad_from_action(event.as_text())
			var asset_paths: Array[String] = ControllerMappings.get_asset(event_type["type"], event_type["index"])

			if asset_paths.is_empty():
				error_text_label.text = "Controller action not supported"
				return

		# Validate event type matches input mode
		if not _is_valid_event_for_input_type(event, SettingsManager.input_type):
			error_text_label.text = "Invalid input event for this action"
			return

		# Prevent double-click from being registered
		if event is InputEventMouseButton and event.double_click:
			event = event.duplicate()
			event.double_click = false

		# Check for existing assignments
		if _is_event_already_assigned(event, SettingsManager.action_to_remap):
			error_text_label.text = "Input event already assigned to another action"
			return

		var current_events: Array[InputEvent] = InputMap.action_get_events(SettingsManager.action_to_remap)
		var split_events: Dictionary = _split_events_by_type(current_events)

		# Replace existing binding of same type
		var old_event: InputEvent = _get_event_to_replace(split_events, SettingsManager.input_type)
		if old_event:
			InputMap.action_erase_event(SettingsManager.action_to_remap, old_event)

		InputMap.action_add_event(SettingsManager.action_to_remap, event)
		_finalize_remapping()
	else:

		if Input.is_action_just_pressed("ui_accept"):
			_activate_focused_button()
		elif event.is_action_pressed("ui_cancel"):
			back_requested.emit()
			UIManager.get_viewport().set_input_as_handled()


func _save_input_settings() -> void:
	var config = ConfigFile.new()
	config.load(config_path) # Load existing settings

	# Skip Godot's built-in UI actions to prevent accidental override
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue

		config.set_value(config_name, action, InputMap.action_get_events(action))

	config.save(config_path)


func _load_input_settings() -> void:
	# Load defaults first, then override with saved config
	InputMap.load_from_project_settings()

	SettingsManager.load_settings(get_viewport(),get_window(),config_name)

	_create_action_list()


func _create_action_list() -> void:
	error_text_label.text = ""

	# Clear existing children
	for child in content_container.get_children():
		content_container.remove_child(child)
		child.queue_free()

	# Add action rows
	for action in InputMap.get_actions():
		if action.begins_with("ui_") or action in ["cycle_debug_menu", "toggle_console"]:
			continue

		var action_row: Node = input_button_resource.instantiate()
		var split_events: Dictionary = _split_events_by_type(InputMap.action_get_events(action))

		action_row.find_child("Label").text = action.capitalize()
		_set_label_text(action_row, "PrimaryPanel", split_events.primary, action)
		_set_label_text(action_row, "SecondaryPanel", split_events.secondary, action)
		_set_controller_icons(action_row, "ControllerPanel", split_events.controller)

		content_container.add_child(action_row)

	SignalManager.focus_lost.emit()


func _trim_mapping_suffix(mapping: String) -> String:
	# Clean up display text by removing technical suffixes
	var cleaned: String = mapping.replace(" (Physical)", "")

	return cleaned.strip_edges().capitalize()


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
			controller = null,
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


func _finalize_remapping() -> void:
	# Update storage and UI after successful remapping
	_save_input_settings()

	SettingsManager.is_remapping = false
	SignalManager.keybind_changed.emit(SettingsManager.action_to_remap)
	SettingsManager.action_to_remap = ""

	_create_action_list()


func _set_label_text(row: Node, container_name: String,
		event: InputEvent,
		action_to_remap: String = ""
	) -> void:
	# Helper to safely set text on labels with fallback
	var panel: RemapPanel = row.find_child(container_name)
	if event:
		panel.button.text = _trim_mapping_suffix(event.as_text())
	else:
		panel.button.text = "Unassigned"
	panel.action_to_remap = action_to_remap


func _set_controller_icons(row: Node, container_name: String,
		event: InputEvent,
		action_to_remap: String = ""
	) -> void:
	# Helper to safely set text on labels with fallback
	var panel: RemapPanel = row.find_child(container_name)
	if not _controller_connected:
		panel.visible = false
		return

	if event:
		panel.container.visible = true

		# Get and display controller icons
		var event_type: Dictionary = ControllerMappings.extract_joypad_from_action(event.as_text())
		var asset_paths: Array[String] = ControllerMappings.get_asset(event_type["type"], event_type["index"])
		# TODO: Handle empty asset_paths
		for path in asset_paths:
			if ResourceLoader.exists(path):  # Check if the texture exists
				var controller_icon: TextureRect = content_item_icon_resource.instantiate()
				controller_icon.texture = load(path)
				panel.container.add_child(controller_icon)
			else:
				push_error("Controller icon not found: ", path)
	else:
		panel.button.text = "Unassigned"
		panel.button.visible = true
		panel.container.visible = false
		panel.button.theme_type_variation = "SettingsKeybindButton"

	panel.action_to_remap = action_to_remap


func _on_restore_defaults_button_up() -> void:
	SettingsManager.is_remapping = false
	SettingsManager.action_to_remap = ""

	# Restore default bindings and remove config file
	InputMap.load_from_project_settings()

	SettingsManager.remove_setting_from_config(config_name)

	_create_action_list()

	SignalManager.keybind_changed.emit("*") 


func _activate_focused_button() -> void:
	var focused: Button = get_viewport().gui_get_focus_owner()
	if focused: focused.pressed.emit()


func _on_controller_changed(device_id: int, connected: bool) -> void:
	_controller_connected = connected

	if connected:
		var controller_name: String = Input.get_joy_name(device_id)
		push_warning("Controller connected: " + controller_name)
	else:
		push_warning("Controller disconnected")

	if SettingsManager.is_remapping:
		SettingsManager.is_remapping = false
		SettingsManager.action_to_remap = ""

	_create_action_list()
