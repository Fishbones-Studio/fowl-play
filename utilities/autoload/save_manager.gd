################################################################################
## Handles all game data persistance, including:
## - Settings (Controls, Key Bindings, Controls, Audio)
## - ...
##
################################################################################
extends Node

const SETTINGS_CONFIG_PATH: String = "user://settings.cfg"
const SETTINGS_CFG_NAME_KEYBINDS: String = "keybinds"
const SETTINGS_CFG_NAME_AUDIO: String = "audio"

# Input remapping 
# Signal would not work here, since signal order is not guaranteed, which can 
# cause multiple input buttons to be pressed at the same time or other bugs
var is_remapping: bool = false
var input_type: SaveEnums.InputType
var action_to_remap: String = ""


## Load all saved settings from the user's configuration file.
func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()

	# Attempt to load config file - return if failed
	if config.load(SETTINGS_CONFIG_PATH) != OK:
		return

	# Load keybind settings
	if config.has_section(SETTINGS_CFG_NAME_KEYBINDS):
		for action in config.get_section_keys(SETTINGS_CFG_NAME_KEYBINDS):
			InputMap.action_erase_events(action)
			for event in config.get_value(SETTINGS_CFG_NAME_KEYBINDS, action):
				InputMap.action_add_event(action, event)

	# Load audio settings
	if config.has_section(SETTINGS_CFG_NAME_AUDIO):
		for audio_bus_name in config.get_section_keys(SETTINGS_CFG_NAME_AUDIO):
			var saved_volume: float = config.get_value(SETTINGS_CFG_NAME_AUDIO, audio_bus_name)

			# Convert percentage to dB and apply; Volume is saved as percentage
			var bus_idx: int = AudioServer.get_bus_index(audio_bus_name)
			var volume: float = linear_to_db(clampf(saved_volume, 0.0, 100.0) / 100)
			AudioServer.set_bus_volume_db(bus_idx, volume)
