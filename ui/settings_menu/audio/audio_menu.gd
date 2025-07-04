################################################################################
## Script to display and manage audio settings in a UI.
##
## This script handles the audio settings UI, allowing users to set the volume 
## of busses and save their preferences.
################################################################################
extends Control

signal back_requested

var config_path: String = "user://settings.cfg"
var config_name: String = "audio"
var audio_busses: Dictionary[String, float]

@onready var audio_slider: PackedScene = preload("uid://6air6r3l5p61")
@onready var content_container: VBoxContainer = %ContentContainer


func _ready() -> void:
	for index in range(AudioServer.get_bus_count()):
		var bus_name: String = AudioServer.get_bus_name(index)
		audio_busses[bus_name] = AudioServer.get_bus_volume_linear(index) * 100

	_load_audio_settings()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		UIManager.get_viewport().set_input_as_handled()


func _load_audio_settings() -> void:
	SettingsManager.load_settings(get_viewport(), get_window(), config_name)

	_load_audio_busses()


func _save_audio_settings() -> void:
	var config = ConfigFile.new()
	config.load(config_path) # Load existing settings

	for audio_bus_name: String in audio_busses:
		config.set_value(config_name, audio_bus_name, audio_busses[audio_bus_name])

	config.save(config_path)


func _load_audio_busses() -> void:
	for child in content_container.get_children():
		content_container.remove_child(child)
		child.queue_free()

	for audio_bus in audio_busses:
		var instance: ContentItemSlider = audio_slider.instantiate()
		content_container.add_child(instance)

		instance.set_text(audio_bus)
		instance.set_value(audio_busses[audio_bus])
		instance.slider.value_changed.connect(_volume_changed.bind(audio_bus))


func _volume_changed(value: float, bus_name: String) -> void:
	_set_volume(bus_name, value)
	_save_audio_settings()


## Set volume for a specific bus (using percentage)
func _set_volume(bus_name: String, volume: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return

	# Convert from percentage to dB
	# Note: 0.0 percent = -80 dB (silent), 1.0 percent = 0 dB (max)
	audio_busses[bus_name] = volume
	volume = linear_to_db(clampf(volume, 0.0, 100.0) / 100)
	AudioServer.set_bus_volume_db(bus_idx, volume)
