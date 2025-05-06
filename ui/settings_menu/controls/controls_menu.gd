################################################################################
### Script to display and manage controls settings in a UI.
###
### This script handles the controls settings UI, allowing users to set the  
### of busses and save their preferences.
################################################################################
extends Control

var config_path: String = "user://settings.cfg"
var config_name: String = "controls"
var controls_settings: Dictionary = {}

@onready var content_container: VBoxContainer = %ContentContainer
@onready var slider_resource: PackedScene = preload("uid://6air6r3l5p61")
@onready var check_button_resource: PackedScene = preload("uid://cukdcvp0jsd4j")
@onready var controls_settings_resource: ControlsSetting = preload("uid://b7ndswiwixuqa")


func _ready() -> void:
	_load_controls_settings()


func _load_controls_settings() -> void:
	var config = ConfigFile.new()

	# Initialize with default settings
	controls_settings = controls_settings_resource.default_settings

	# Try to load config file
	if config.load(config_path) == OK and config.has_section(config_name):
		# Override defaults with saved settings
		for controls_setting in config.get_section_keys(config_name):
			controls_settings[controls_setting] = config.get_value(config_name, controls_setting)
	print(controls_settings_resource.default_settings)
	_load_controls_items()


func _save_controls_settings() -> void:
	var config = ConfigFile.new()
	config.load(config_path) # Load existing settings

	for controls_setting: String in controls_settings:
		config.set_value(config_name, controls_setting, controls_settings[controls_setting])

	config.save(config_path)
	SignalManager.controls_settings_changed.emit()


func _load_controls_items() -> void:
	for child in content_container.get_children():
		content_container.remove_child(child)
		child.queue_free()

	for item: String in controls_settings:
		match controls_settings[item]["type"]:
			"slider":
				var slider: SettingsSlider = slider_resource.instantiate()
				content_container.add_child(slider)
				slider.label.text = item.capitalize()
				slider.slider.min_value = controls_settings[item]["min"]
				slider.slider.max_value = controls_settings[item]["max"]
				slider.slider.step = controls_settings[item]["step"]
				slider.slider.value = controls_settings[item]["value"]
				slider.slider.value_changed.connect(_value_changed.bind(item))
			"check_button":
				var check_button: SettingsCheckButton = check_button_resource.instantiate()
				content_container.add_child(check_button)
				check_button.set_pressed_no_signal(controls_settings[item]["value"])
				check_button.label.text = item.capitalize()
				check_button.toggled.connect(_value_changed.bind(item))


func _value_changed(value: float, item: String) -> void:
	controls_settings[item]["value"] = value

	_save_controls_settings()
