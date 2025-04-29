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
const SAVE_GAME_PATH: String = "user://save_game.tres"

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
			
func save_game(stats: LivingEntityStats, upgrades: Dictionary) -> void:
	if stats == null:
		push_error("Cannot save game: statis is null")
		return
	var save_data = {
		"stats": {
			"health": stats.max_health,
			"stamina": stats.max_stamina,
			"attack_multiplier": stats.attack_multiplier,
			"defence": stats.defense,
			"speed": stats.speed,
			"weight": stats.weight,
		},
		"upgrades": upgrades
	}
	print("Saving game data:", save_data)
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open file for writing: ", SAVE_GAME_PATH)
		return
	file.store_var(save_data)
	file.close()
	print("Game data saved successfully!")
	
func load_game(stats: LivingEntityStats) -> Dictionary:
	if FileAccess.file_exists(SAVE_GAME_PATH):
		var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
		var save_data = file.get_var()
		file.close()
		
		if save_data.has("stats"):
			stats.max_health = save_data["stats"].get("health", stats.max_health)
			stats.max_stamina = save_data["stats"].get("stamina", stats.max_stamina)
			stats.attack_multiplier = save_data["stats"].get("attack_multiplier", stats.attack_multiplier)
			stats.defense = save_data["stats"].get("defense", stats.defense)
			stats.weight = save_data["stats"].get("weight", stats.weight)
			
		return save_data.get("upgrades", {})
	return {}
			 
	
