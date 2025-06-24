################################################################################
### Script to display and manage controls settings in a UI.
###
### This script handles the controls settings UI, allowing users to set game 
### control settings. Handles both mouse and controller configurations.
################################################################################
extends Control

signal back_requested

var config_path: String = "user://settings.cfg"
var config_name: String = "controls"
var controls_settings: Array[Dictionary] = []

@onready var content_container: VBoxContainer = %ContentContainer
@onready var slider_resource: PackedScene = preload("uid://6air6r3l5p61")
@onready var check_button_resource: PackedScene = preload("uid://cukdcvp0jsd4j")
@onready var controls_settings_resource: ControlsSetting = preload("uid://b7ndswiwixuqa")


func _ready() -> void:
	_load_controls_settings()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		UIManager.get_viewport().set_input_as_handled()

func _load_controls_settings() -> void:
	var config = ConfigFile.new()

	# Initialize with default settings
	controls_settings = controls_settings_resource.default_settings.duplicate(true)

	# Try to load config file
	if config.load(config_path) == OK and config.has_section(config_name):
		controls_settings.clear()
		# Override defaults with saved settings
		for controls_setting in config.get_section_keys(config_name):
			controls_settings.append({
				controls_setting: config.get_value(config_name, controls_setting)
				})

	_load_controls_items()


func _save_controls_settings() -> void:
	var config = ConfigFile.new()
	config.load(config_path) # Load existing settings

	for controls_setting: Dictionary in controls_settings:
		config.set_value(config_name, controls_setting.keys()[0], controls_setting.values()[0])

	config.save(config_path)
	SignalManager.controls_settings_changed.emit()


func _load_controls_items() -> void:
	for child in content_container.get_children():
		content_container.remove_child(child)
		child.queue_free()

	for item: Dictionary in controls_settings:
		var item_name: String = item.keys()[0]
		var item_values: Dictionary = item.values()[0]

		match item_values["type"]:
			"slider":
				var slider: ContentItemSlider = slider_resource.instantiate()
				content_container.add_child(slider)
				slider.label.text = item_name.capitalize()
				slider.slider.min_value = item_values["min"]
				slider.slider.max_value = item_values["max"]
				slider.slider.step = item_values["step"]
				slider.slider.value = item_values["value"]
				slider.slider.value_changed.connect(_value_changed.bind(item))
			"check_button":
				var check_button: ContentItemCheckButton = check_button_resource.instantiate()
				content_container.add_child(check_button)
				check_button.set_pressed_no_signal(item_values["value"])
				check_button.label.text = item_name.capitalize()
				check_button.toggled.connect(_value_changed.bind(item))


func _value_changed(value: float, item: Dictionary) -> void:
	controls_settings[controls_settings.find(item)].values()[0]["value"] = value

	_save_controls_settings()


func _on_restore_defaults_button_up() -> void:
	SettingsManager.remove_setting_from_config(config_name)

	controls_settings.clear()
	controls_settings = controls_settings_resource.default_settings.duplicate(true)

	_load_controls_items()
	_save_controls_settings()
