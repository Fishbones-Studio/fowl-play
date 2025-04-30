################################################################################
## Handles all game data persistance, including:
## - Settings (Controls, Key Bindings, Controls, Audio)
## - Save Game Data (Stats, Upgrades)
##
################################################################################
extends Node

const SETTINGS_CONFIG_PATH: String = "user://settings.cfg"
const SETTINGS_CFG_NAME_KEYBINDS: String = "keybinds"
const SETTINGS_CFG_NAME_AUDIO: String = "audio"
const SAVE_GAME_PATH: String = "user://save_game.cfg"
const PLAYER_SAVE_SECTION: String = "player"

# Input remapping 
# Signal would not work here, since signal order is not guaranteed, which can 
# cause multiple input buttons to be pressed at the same time or other bugs
var is_remapping: bool = false
var input_type: SaveEnums.InputType
var action_to_remap: String = ""

# Cache for loaded game data
var _loaded_game_data: Dictionary = {}

## Load all saved settings from the user's configuration file.
func load_settings() -> void:
	var config := ConfigFile.new()
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
			var bus_idx: int = AudioServer.get_bus_index(audio_bus_name)
			var volume: float = linear_to_db(clampf(saved_volume, 0.0, 100.0) / 100)
			AudioServer.set_bus_volume_db(bus_idx, volume)

func save_game(stats: LivingEntityStats, upgrades: Dictionary) -> void:
	if stats == null:
		push_error("Cannot save game: stats is null")
		return

	var config := ConfigFile.new()
	# Serialize stats and upgrades
	config.set_value(PLAYER_SAVE_SECTION, "stats", stats.to_dict())
	config.set_value(PLAYER_SAVE_SECTION, "upgrades", upgrades)
	var err := config.save(SAVE_GAME_PATH)
	if err != OK:
		push_error("Failed to save game: %s" % error_string(err))
		return

	_loaded_game_data = {
		"stats": stats.to_dict(),
		"upgrades": upgrades
	}
	print("Game data saved successfully!")

func load_game() -> Dictionary:
	if not _loaded_game_data.is_empty():
		return _loaded_game_data

	var config := ConfigFile.new()
	if config.load(SAVE_GAME_PATH) != OK:
		push_warning("Failed to load game data from %s" % SAVE_GAME_PATH)
		save_game(ResourceLoader.load("uid://bwhuhbesdlyu5").duplicate(), {})
		load_game()

	var stats_dict = config.get_value(PLAYER_SAVE_SECTION, "stats", null)
	var upgrades = config.get_value(PLAYER_SAVE_SECTION, "upgrades", {})

	var stats: LivingEntityStats = null
	if stats_dict != null && stats_dict is Dictionary:
		# Attempt to load stats from the save file
		stats = LivingEntityStats.from_dict(stats_dict)
	else:
		# Loading the default player stats
		stats = ResourceLoader.load("uid://bwhuhbesdlyu5").duplicate()

	_loaded_game_data = {
		"stats": stats,
		"upgrades": upgrades
	}
	return _loaded_game_data
	
func reset_game() -> void:
	var default_stats: LivingEntityStats = ResourceLoader.load("uid://bwhuhbesdlyu5").duplicate()
	save_game(default_stats, {})

func get_loaded_player_stats() -> LivingEntityStats:
	if _loaded_game_data.is_empty():
		load_game()
	return _loaded_game_data.get("stats", null)

func get_loaded_player_upgrades() -> Dictionary:
	if _loaded_game_data.is_empty():
		load_game()
	return _loaded_game_data.get("upgrades", {})
