################################################################################
## Handles all game data persistance, including:
## - Settings (Controls, Key Bindings, Graphics, Audio)
## - Save Game Data (Stats, Upgrades)
##
################################################################################
extends Node

const SETTINGS_CONFIG_PATH: String = "user://settings.cfg"
const SETTINGS_CFG_NAME_CONTROLS: String = "controls"
const SETTINGS_CFG_NAME_KEYBINDS: String = "keybinds"
const SETTINGS_CFG_NAME_GRAPHICS: String = "graphics"
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
func load_settings(item: String = "") -> void:
	var config := ConfigFile.new()

	# Attempt to load config file - return if failed
	if config.load(SETTINGS_CONFIG_PATH) != OK:
		return

	if item == SETTINGS_CFG_NAME_CONTROLS or item.is_empty():
		pass

	if item == SETTINGS_CFG_NAME_KEYBINDS or item.is_empty():
		# Load keybind settings
		if config.has_section(SETTINGS_CFG_NAME_KEYBINDS):
			for action in config.get_section_keys(SETTINGS_CFG_NAME_KEYBINDS):
				InputMap.action_erase_events(action)
				for event in config.get_value(SETTINGS_CFG_NAME_KEYBINDS, action):
					InputMap.action_add_event(action, event)

	if item == SETTINGS_CFG_NAME_GRAPHICS or item.is_empty():
		if config.has_section(SETTINGS_CFG_NAME_GRAPHICS):
			var resolution: Vector2i
			for graphics_setting in config.get_section_keys(SETTINGS_CFG_NAME_GRAPHICS):
				var value = config.get_value(SETTINGS_CFG_NAME_GRAPHICS, graphics_setting)
				match graphics_setting:
					"resolution":
						resolution = value
						DisplayServer.window_set_size(value)
						DisplayUtils.center_window(get_window())
					"display_mode": DisplayServer.window_set_mode(value)
					"borderless": 
						DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, value)
						DisplayServer.window_set_size(resolution)
						DisplayUtils.center_window(get_window())
					"v_sync": DisplayServer.window_set_vsync_mode(value)
					"fps": Engine.max_fps = value

	if item == SETTINGS_CFG_NAME_AUDIO or item.is_empty():
		# Load audio settings
		if config.has_section(SETTINGS_CFG_NAME_AUDIO):
			for audio_bus_name in config.get_section_keys(SETTINGS_CFG_NAME_AUDIO):
				var saved_volume: float = config.get_value(SETTINGS_CFG_NAME_AUDIO, audio_bus_name)
				var bus_idx: int = AudioServer.get_bus_index(audio_bus_name)
				var volume: float = linear_to_db(clampf(saved_volume, 0.0, 100.0) / 100)
				AudioServer.set_bus_volume_db(bus_idx, volume)


func save_game(stats: LivingEntityStats = null, upgrades: Dictionary[StatsEnums.UpgradeTypes, int] = {}) -> void:
	# Try to load the config file
	var config := ConfigFile.new()
	config.load(SAVE_GAME_PATH)

	# Serialize stats and upgrades
	if stats:
		config.set_value(PLAYER_SAVE_SECTION, "stats", stats.to_dict())
	if upgrades:
		config.set_value(PLAYER_SAVE_SECTION, "upgrades", upgrades)
	config.set_value(PLAYER_SAVE_SECTION, "f_o_r", GameManager.feathers_of_rebirth)
	config.set_value(PLAYER_SAVE_SECTION, "p_eggs", GameManager.prosperity_eggs)
	var err := config.save(SAVE_GAME_PATH)
	if err != OK:
		push_error("Failed to save game: %s" % error_string(err))
		return

	# Updating loaded stats
	if stats:
		_loaded_game_data["stats"] = stats
	if upgrades:
		print("Saving upgrades: ", upgrades)
		# Saves upgrade type and its level
		_loaded_game_data["upgrades"] = upgrades
	else:
		print("No upgrades to save.")
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
	GameManager.feathers_of_rebirth = config.get_value(PLAYER_SAVE_SECTION, "f_o_r", 0)
	GameManager.prosperity_eggs = config.get_value(PLAYER_SAVE_SECTION, "p_eggs", 200) # Default value

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
	var default_upgrades: Dictionary[StatsEnums.UpgradeTypes, int] = {
		StatsEnums.UpgradeTypes.MAX_HEALTH: 0,
		StatsEnums.UpgradeTypes.DEFENSE: 0,
		StatsEnums.UpgradeTypes.STAMINA: 0,
		StatsEnums.UpgradeTypes.WEIGHT: 0,
		StatsEnums.UpgradeTypes.DAMAGE: 0,
		StatsEnums.UpgradeTypes.SPEED: 0
	}
	
	_loaded_game_data = {}
	
	save_game(default_stats, default_upgrades)
	print("Game Reset - Stats: ", default_stats.to_dict())
	print("Game Reset - Upgrades", default_upgrades)


func get_loaded_player_stats() -> LivingEntityStats:
	if _loaded_game_data.is_empty():
		load_game()
	print("Loaded Upgrades: ", _loaded_game_data.get("upgrades", {}))
	return _loaded_game_data.get("stats", null).duplicate()


func get_loaded_player_upgrades() -> Dictionary[StatsEnums.UpgradeTypes, int]:
	if _loaded_game_data.is_empty():
		load_game()

	var upgrades: Dictionary = _loaded_game_data.get("upgrades", {})
	var typed_upgrades: Dictionary[StatsEnums.UpgradeTypes, int] = {}

	for key in upgrades.keys():
		# Ensure the key from the save file is actually an integer
		if typeof(key) == TYPE_INT:
			# Cast the integer key directly to the enum type
			var upgrade_type: StatsEnums.UpgradeTypes = key as StatsEnums.UpgradeTypes
			# Get the corresponding value (upgrade level)
			var upgrade_level: int = upgrades[key] as int

			# Check if the value is indeed an integer
			if typeof(upgrade_level) == TYPE_INT:
				typed_upgrades[upgrade_type] = upgrade_level
			else:
				printerr(
					"Warning: Invalid value type for upgrade key ",
					key,
					" in saved data. Expected int, got: ",
					typeof(upgrades[key])
				)
		else:
			printerr(
				"Warning: Invalid key type found in saved upgrades: ",
				key,
				". Expected int, got: ",
				typeof(key)
			)

	return typed_upgrades
