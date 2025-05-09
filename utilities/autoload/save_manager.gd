################################################################################
## Handles game data persistance, including:
## - Save Game Data (Stats, Upgrades, Rounds Won, Enemy Encounters)
################################################################################
extends Node


const SAVE_GAME_PATH: String = "user://save_game.cfg"
const PLAYER_SAVE_SECTION: String = "player"

# Default player stats resource
const DEFAULT_PLAYER_STATS_PATH: String = "uid://bwhuhbesdlyu5"


# Cache for loaded game data
var _loaded_game_data: Dictionary = {}


func _load_game_config() -> ConfigFile:
	var config := ConfigFile.new()
	# Don't create the file if it doesn't exist, load_game handles defaults
	config.load(SAVE_GAME_PATH)
	return config

func _save_game_config(config: ConfigFile) -> void:
	var err := config.save(SAVE_GAME_PATH)
	if err != OK:
		push_error("Failed to save game config: %s" % error_string(err))

func _ensure_game_data_loaded():
	if _loaded_game_data.is_empty():
		load_game_data()

func _get_default_player_stats() -> LivingEntityStats:
	var default_stats_res: Resource = ResourceLoader.load(DEFAULT_PLAYER_STATS_PATH)
	if default_stats_res is LivingEntityStats:
		return default_stats_res.duplicate()
	push_error("Failed to load default player stats from path: %s" % DEFAULT_PLAYER_STATS_PATH)
	return LivingEntityStats.new() # Fallback to a new instance if loading fails

func _get_default_upgrades() -> Dictionary[StatsEnums.UpgradeTypes, int]:
	return {
		StatsEnums.UpgradeTypes.MAX_HEALTH: 0,
		StatsEnums.UpgradeTypes.DEFENSE: 0,
		StatsEnums.UpgradeTypes.STAMINA: 0,
		StatsEnums.UpgradeTypes.WEIGHT: 0,
		StatsEnums.UpgradeTypes.DAMAGE: 0,
		StatsEnums.UpgradeTypes.SPEED: 0
	}


func save_player_stats(stats: LivingEntityStats) -> void:
	_ensure_game_data_loaded() # Ensure cache is populated
	var config := _load_game_config()
	config.set_value(PLAYER_SAVE_SECTION, "stats", stats.to_dict())
	_save_game_config(config)
	_loaded_game_data["stats"] = stats
	print("Player stats saved.")

func save_player_upgrades(upgrades: Dictionary[StatsEnums.UpgradeTypes, int]) -> void:
	_ensure_game_data_loaded()
	var config := _load_game_config()
	config.set_value(PLAYER_SAVE_SECTION, "upgrades", upgrades)
	_save_game_config(config)
	_loaded_game_data["upgrades"] = upgrades
	print("Player upgrades saved: ", upgrades)
	
func save_currency(feathers: int, eggs: int) -> void:
	_ensure_game_data_loaded()
	var config := _load_game_config()
	config.set_value(PLAYER_SAVE_SECTION, "f_o_r", feathers)
	config.set_value(PLAYER_SAVE_SECTION, "p_eggs", eggs)
	_save_game_config(config)
	_loaded_game_data["f_o_r"] = feathers
	_loaded_game_data["p_eggs"] = eggs
	print("Currency saved: Feathers of Rebirth: ", feathers, ", Prosperity Eggs: ", eggs)

func save_rounds_won(rounds: int) -> void:
	_ensure_game_data_loaded()
	var config := _load_game_config()
	config.set_value(PLAYER_SAVE_SECTION, "rounds_won", rounds)
	_save_game_config(config)
	_loaded_game_data["rounds_won"] = rounds
	print("Rounds won saved: ", rounds)

func save_enemy_encounters(encounters: Dictionary[String, int]) -> void:
	_ensure_game_data_loaded()
	var config := _load_game_config()
	config.set_value(PLAYER_SAVE_SECTION, "enemy_encounters", encounters)
	_save_game_config(config)
	_loaded_game_data["enemy_encounters"] = encounters
	print("Enemy encounters saved: ", encounters)

func load_game_data() -> Dictionary:
	if not _loaded_game_data.is_empty():
		return _loaded_game_data

	var config := ConfigFile.new()
	var stats: LivingEntityStats
	var upgrades: Dictionary[StatsEnums.UpgradeTypes, int]
	var rounds_won: int
	var enemy_encounters: Dictionary[String, int]
	var feathers_of_rebirth: int
	var prosperity_eggs: int

	if config.load(SAVE_GAME_PATH) != OK:
		push_warning("Failed to load game data from %s. Creating default save." % SAVE_GAME_PATH)
		stats = _get_default_player_stats()
		upgrades = _get_default_upgrades()
		rounds_won = 0
		enemy_encounters = {}
		feathers_of_rebirth = 0
		prosperity_eggs = 200
		# Create a new save file with defaults
		_create_default_save_file(stats, upgrades, rounds_won, enemy_encounters, feathers_of_rebirth, prosperity_eggs)
	else:
		var stats_dict = config.get_value(PLAYER_SAVE_SECTION, "stats", null)
		if stats_dict != null && stats_dict is Dictionary[StatsEnums.UpgradeTypes, int]:
			stats = LivingEntityStats.from_dict(stats_dict)
		else:
			stats = _get_default_player_stats()

		upgrades = config.get_value(PLAYER_SAVE_SECTION, "upgrades", _get_default_upgrades())
		rounds_won = config.get_value(PLAYER_SAVE_SECTION, "rounds_won", 0)
		enemy_encounters = config.get_value(PLAYER_SAVE_SECTION, "enemy_encounters", {})
		feathers_of_rebirth = config.get_value(PLAYER_SAVE_SECTION, "f_o_r", 0)
		prosperity_eggs = config.get_value(PLAYER_SAVE_SECTION, "p_eggs", 200)

	# Update GameManager properties directly after loading
	if GameManager: # Check if GameManager autoload/singleton exists
		GameManager.feathers_of_rebirth = feathers_of_rebirth
		GameManager.prosperity_eggs = prosperity_eggs
	else:
		push_warning("GameManager not found. Feathers of Rebirth and Prosperity Eggs not updated.")


	_loaded_game_data = {
		"stats": stats,
		"upgrades": upgrades,
		"rounds_won": rounds_won,
		"enemy_encounters": enemy_encounters,
		"f_o_r": feathers_of_rebirth,
		"p_eggs": prosperity_eggs
	}
	
	print("Game data loaded.")
	return _loaded_game_data

func _create_default_save_file(stats: LivingEntityStats, upgrades: Dictionary[StatsEnums.UpgradeTypes, int], rounds_won: int, enemy_encounters: Dictionary[String, int], feathers: int, eggs: int) -> void:
	var config := ConfigFile.new()
	config.set_value(PLAYER_SAVE_SECTION, "stats", stats.to_dict())
	config.set_value(PLAYER_SAVE_SECTION, "upgrades", upgrades)
	config.set_value(PLAYER_SAVE_SECTION, "rounds_won", rounds_won)
	config.set_value(PLAYER_SAVE_SECTION, "enemy_encounters", enemy_encounters)
	config.set_value(PLAYER_SAVE_SECTION, "f_o_r", feathers)
	config.set_value(PLAYER_SAVE_SECTION, "p_eggs", eggs)
	_save_game_config(config)


func reset_game_data() -> void:
	var default_stats: LivingEntityStats = _get_default_player_stats()
	var default_upgrades: Dictionary[StatsEnums.UpgradeTypes, int] = _get_default_upgrades()
	var default_rounds_won: int = 0
	var default_enemy_encounters: Dictionary[String, int] = {}
	var default_feathers: int = 0
	var default_eggs: int = 200 # Default prosperity eggs

	_loaded_game_data = { # Clear cache and set to defaults
		"stats": default_stats,
		"upgrades": default_upgrades,
		"rounds_won": default_rounds_won,
		"enemy_encounters": default_enemy_encounters,
		"f_o_r": default_feathers,
		"p_eggs": default_eggs
	}
	_create_default_save_file(default_stats, default_upgrades, default_rounds_won, default_enemy_encounters, default_feathers, default_eggs)

	# Also update GameManager if it exists
	if GameManager:
		GameManager.feathers_of_rebirth = default_feathers
		GameManager.prosperity_eggs = default_eggs

	print("Game data reset.")
	print("Reset Stats: ", default_stats.to_dict())
	print("Reset Upgrades: ", default_upgrades)
	print("Reset Rounds Won: ", default_rounds_won)
	print("Reset Enemy Encounters: ", default_enemy_encounters)


func get_loaded_player_stats() -> LivingEntityStats:
	_ensure_game_data_loaded()
	var stats = _loaded_game_data.get("stats", null)
	if stats is LivingEntityStats:
		return stats.duplicate() # Return a copy to prevent direct modification of cached data
	return _get_default_player_stats() # Fallback

func get_loaded_player_upgrades() -> Dictionary[StatsEnums.UpgradeTypes, int]: # Return type Dictionary[StatsEnums.UpgradeTypes, int]
	_ensure_game_data_loaded()
	var upgrades: Dictionary = _loaded_game_data.get("upgrades", {})
	var typed_upgrades : Dictionary[StatsEnums.UpgradeTypes, int] = {}

	# Perform type checking and conversion as in the original
	for key in upgrades.keys():
		var upgrade_type_candidate = key
		var upgrade_level_candidate = upgrades[key]

		# Attempt to ensure key is int (for enum) and value is int
		if typeof(upgrade_type_candidate) == TYPE_INT and typeof(upgrade_level_candidate) == TYPE_INT:
			typed_upgrades[int(upgrade_type_candidate)] = int(upgrade_level_candidate)
		else:
			printerr(
					"Warning: Invalid key/value type for upgrade in saved data. Key: ",
					key, " (", typeof(key), "), Value: ", upgrades[key], " (", typeof(upgrades[key]), ")"
				)
	return typed_upgrades


func get_loaded_rounds_won() -> int:
	_ensure_game_data_loaded()
	return _loaded_game_data.get("rounds_won", 0)

func get_loaded_enemy_encounters() -> Dictionary[String, int]:
	_ensure_game_data_loaded()
	var encounters = _loaded_game_data.get("enemy_encounters", {})
	if encounters is Dictionary[String, int]:
		return encounters.duplicate() # Return a copy
	return {} # Fallback
	
