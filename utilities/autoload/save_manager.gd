################################################################################
## Handles game data persistance, including:
## - Save Game Data (Stats, Upgrades, Rounds Won, Enemy Encounters, Currency)
################################################################################
extends Node

const SAVE_GAME_PATH: String = "user://save_game.cfg"
const PLAYER_SAVE_SECTION: String = "player"
const WORLD_SAVE_SECTION: String = "world"
const CURRENCY_SAVE_SECTION: String = "currency"

# Default player stats resource
const DEFAULT_PLAYER_STATS_PATH: String = "uid://bwhuhbesdlyu5"

# Cache for loaded game data
var _loaded_game_data: Dictionary = {}

func _load_game_config() -> ConfigFile:
	var config := ConfigFile.new()
	config.load(SAVE_GAME_PATH)
	return config

func _save_game_config(config: ConfigFile) -> void:
	var err: Error = config.save(SAVE_GAME_PATH)
	if err != OK:
		push_error(
			"Failed to save game config: %s" % error_string(err)
		)

func _ensure_game_data_loaded() -> void:
	if _loaded_game_data.is_empty():
		load_game_data()

func _get_default_player_stats() -> LivingEntityStats:
	var default_stats_res: Resource = ResourceLoader.load(
		DEFAULT_PLAYER_STATS_PATH
	)
	if default_stats_res is LivingEntityStats:
		# Explicit cast before calling duplicate for clarity and safety
		return (default_stats_res as LivingEntityStats).duplicate()
	push_error(
		"Failed to load default player stats from path: %s"
		% DEFAULT_PLAYER_STATS_PATH
	)
	return LivingEntityStats.new()

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
	_ensure_game_data_loaded()
	var config := _load_game_config()
	config.set_value(PLAYER_SAVE_SECTION, "stats", stats.to_dict())
	_save_game_config(config)
	_loaded_game_data["stats"] = stats
	print("Player stats saved.")

func save_player_upgrades(
	upgrades: Dictionary[StatsEnums.UpgradeTypes, int]
) -> void:
	_ensure_game_data_loaded()
	var config := _load_game_config()
	# ConfigFile will save enum keys as their integer values
	config.set_value(PLAYER_SAVE_SECTION, "upgrades", upgrades)
	_save_game_config(config)
	_loaded_game_data["upgrades"] = upgrades.duplicate()
	print("Player upgrades saved: ", upgrades)

func save_currency(feathers: int, eggs: int) -> void:
	_ensure_game_data_loaded()
	var config := _load_game_config()
	config.set_value(CURRENCY_SAVE_SECTION, "f_o_r", feathers)
	config.set_value(CURRENCY_SAVE_SECTION, "p_eggs", eggs)
	_save_game_config(config)
	_loaded_game_data["f_o_r"] = feathers
	_loaded_game_data["p_eggs"] = eggs
	print(
		"Currency saved: Feathers of Rebirth: ",
		feathers,
		", Prosperity Eggs: ",
		eggs
	)

# Helper function to increment rounds_won (player section) and total_rounds_won (world section)
func save_rounds_one_by_one() -> void:
	_ensure_game_data_loaded()
	var current_rounds_won: int = get_loaded_rounds_won()
	var current_total_rounds_won: int = get_loaded_total_rounds_won()
	save_rounds_won(current_rounds_won + 1)
	save_total_rounds_won(current_total_rounds_won + 1)

func save_rounds_won(rounds: int) -> void:
	_ensure_game_data_loaded()
	var config := _load_game_config()
	config.set_value(PLAYER_SAVE_SECTION, "rounds_won", rounds)
	_save_game_config(config)
	_loaded_game_data["rounds_won"] = rounds
	print("Rounds won saved: ", rounds)

# Helper for total_rounds_won (world section, persists)
func save_total_rounds_won(total_rounds: int) -> void:
	_ensure_game_data_loaded()
	var config := _load_game_config()
	config.set_value(WORLD_SAVE_SECTION, "total_rounds_won", total_rounds)
	_save_game_config(config)
	_loaded_game_data["total_rounds_won"] = total_rounds
	print("Total rounds won saved: ", total_rounds)

# Helper function to increment enemy encounters
func save_enemy_encounter(enemy_name: String) -> void:
	enemy_name = enemy_name.to_lower()
	_ensure_game_data_loaded()
	var encounters: Dictionary[String, int] = get_loaded_enemy_encounters()
	if encounters.has(enemy_name):
		encounters[enemy_name] += 1
	else:
		encounters[enemy_name] = 1
	save_enemy_encounters(encounters)

func save_enemy_encounters(encounters: Dictionary[String, int]) -> void:
	_ensure_game_data_loaded()
	var config := _load_game_config()
	config.set_value(WORLD_SAVE_SECTION, "enemy_encounters", encounters)
	_save_game_config(config)
	_loaded_game_data["enemy_encounters"] = encounters.duplicate()
	print("Enemy encounters saved: ", encounters)

func load_game_data() -> Dictionary:
	if not _loaded_game_data.is_empty():
		return _loaded_game_data

	var config := ConfigFile.new()

	var final_stats: LivingEntityStats
	var final_upgrades: Dictionary
	var final_rounds_won: int
	var final_total_rounds_won: int
	var final_enemy_encounters: Dictionary[String, int]
	var final_feathers_of_rebirth: int
	var final_prosperity_eggs: int

	if config.load(SAVE_GAME_PATH) != OK:
		push_warning(
			"Failed to load game data from %s. Creating default save."
			% SAVE_GAME_PATH
		)
		final_stats = _get_default_player_stats()
		final_upgrades = _get_default_upgrades()
		final_rounds_won = 0
		final_total_rounds_won = 0
		final_enemy_encounters = {} as Dictionary[String, int]
		final_feathers_of_rebirth = 0
		final_prosperity_eggs = 200
		_create_default_save_file(
			final_stats,
			final_upgrades,
			final_rounds_won,
			final_total_rounds_won,
			final_enemy_encounters,
			final_feathers_of_rebirth,
			final_prosperity_eggs
		)
	else:
		# Load stats
		var stats_variant: Variant = config.get_value(
			PLAYER_SAVE_SECTION, "stats", null
		)
		if stats_variant is Dictionary:
			var parsed_stats: LivingEntityStats = LivingEntityStats.from_dict(
				stats_variant as Dictionary
			)
			if parsed_stats is LivingEntityStats:
				final_stats = parsed_stats
			else:
				push_warning(
					"Failed to parse player stats from dictionary. Using defaults."
				)
				final_stats = _get_default_player_stats()
		else:
			if stats_variant != null:
				push_warning(
					"Player stats in save file is not a Dictionary. Using defaults."
				)
			final_stats = _get_default_player_stats()

		var upgrades_variant: Variant = config.get_value(
			PLAYER_SAVE_SECTION, "upgrades", null
		)
		if upgrades_variant is Dictionary:
			final_upgrades = upgrades_variant as Dictionary
		else:
			if upgrades_variant != null:
				push_warning(
					"Player upgrades in save file is not a Dictionary. Using defaults."
				)
			final_upgrades = _get_default_upgrades()

		# Load rounds_won from player section
		final_rounds_won = config.get_value(
			PLAYER_SAVE_SECTION, "rounds_won", 0
		) as int

		# Load total_rounds_won from world section
		final_total_rounds_won = config.get_value(
			WORLD_SAVE_SECTION, "total_rounds_won", 0
		) as int

		# Load enemy_encounters from world section
		var encounters_variant: Variant = config.get_value(
			WORLD_SAVE_SECTION, "enemy_encounters", null
		)
		var parsed_encounters: Dictionary[String, int] = {}
		if encounters_variant is Dictionary:
			var encounters_dict_raw: Dictionary = encounters_variant as Dictionary
			var all_valid: bool = true
			for k_var in encounters_dict_raw:
				var v_var = encounters_dict_raw[k_var]
				if k_var is String and typeof(v_var) == TYPE_INT:
					parsed_encounters[k_var as String] = v_var as int
				else:
					push_warning(
						"Invalid enemy encounter entry in save: Key '%s', Value '%s'. Skipping."
						% [k_var, v_var]
					)
					all_valid = false
			if not all_valid and not parsed_encounters.is_empty():
				push_warning(
					"Some enemy encounter entries were invalid but others were loaded."
				)
			elif not all_valid and parsed_encounters.is_empty() and not encounters_dict_raw.is_empty():
				push_warning(
					"All loaded enemy encounter entries were invalid. Using empty default."
				)
			final_enemy_encounters = parsed_encounters
		else:
			if encounters_variant != null:
				push_warning(
					"Enemy encounters in save file is not a Dictionary. Using empty default."
				)
			final_enemy_encounters = {}

		# Load currency from currency section
		final_feathers_of_rebirth = config.get_value(
			CURRENCY_SAVE_SECTION, "f_o_r", 0
		) as int
		final_prosperity_eggs = config.get_value(
			CURRENCY_SAVE_SECTION, "p_eggs", 200
		) as int

	if GameManager:
		GameManager.feathers_of_rebirth = final_feathers_of_rebirth
		GameManager.prosperity_eggs = final_prosperity_eggs
	else:
		push_warning(
			"GameManager not found. Feathers of Rebirth and Prosperity Eggs not updated."
		)

	_loaded_game_data = {
		"stats": final_stats,
		"upgrades": final_upgrades,
		"rounds_won": final_rounds_won,
		"total_rounds_won": final_total_rounds_won,
		"enemy_encounters": final_enemy_encounters,
		"f_o_r": final_feathers_of_rebirth,
		"p_eggs": final_prosperity_eggs
	}

	print("Game data loaded.")
	return _loaded_game_data

func _create_default_save_file(
	stats: LivingEntityStats,
	upgrades: Dictionary[StatsEnums.UpgradeTypes, int],
	rounds_won: int,
	total_rounds_won: int,
	enemy_encounters: Dictionary[String, int],
	feathers: int,
	eggs: int
) -> void:
	var config := ConfigFile.new()
	config.set_value(PLAYER_SAVE_SECTION, "stats", stats.to_dict())
	config.set_value(PLAYER_SAVE_SECTION, "upgrades", upgrades)
	config.set_value(PLAYER_SAVE_SECTION, "rounds_won", rounds_won)
	config.set_value(WORLD_SAVE_SECTION, "total_rounds_won", total_rounds_won)
	config.set_value(WORLD_SAVE_SECTION, "enemy_encounters", enemy_encounters)
	config.set_value(CURRENCY_SAVE_SECTION, "f_o_r", feathers)
	config.set_value(CURRENCY_SAVE_SECTION, "p_eggs", eggs)
	_save_game_config(config)

func reset_game_data() -> void:
	var default_stats: LivingEntityStats = _get_default_player_stats()
	var upgrades: Dictionary[StatsEnums.UpgradeTypes, int] = get_loaded_player_upgrades()
	var default_rounds_won: int = 0
	var default_enemy_encounters: Dictionary[String, int] = (
		{} as Dictionary[String, int]
	)
	var total_rounds_won: int = get_loaded_total_rounds_won() # persist total

	_loaded_game_data = {
		"stats": default_stats,
		"upgrades": upgrades,
		"rounds_won": default_rounds_won,
		"total_rounds_won": total_rounds_won,
		"enemy_encounters": default_enemy_encounters,
		"f_o_r": GameManager.feathers_of_rebirth,
		"p_eggs": GameManager.prosperity_eggs
	}
	_create_default_save_file(
		default_stats,
		upgrades,
		default_rounds_won,
		total_rounds_won,
		default_enemy_encounters,
		GameManager.feathers_of_rebirth,
		GameManager.prosperity_eggs
	)

	print("Game data reset.")
	print("Reset Stats: ", default_stats.to_dict())
	print("Reset Upgrades: ", upgrades)
	print("Reset Rounds Won: ", default_rounds_won)
	print("Reset Enemy Encounters: ", default_enemy_encounters)
	print("Total Rounds Won (persisted): ", total_rounds_won)

func get_loaded_player_stats() -> LivingEntityStats:
	_ensure_game_data_loaded()
	var stats_variant = _loaded_game_data.get("stats")
	if stats_variant is LivingEntityStats:
		return (stats_variant as LivingEntityStats).duplicate()
	push_error(
		"Cached player stats are not of type LivingEntityStats or missing. Returning default."
	)
	return _get_default_player_stats()

func get_loaded_player_upgrades() -> Dictionary[StatsEnums.UpgradeTypes, int]:
	_ensure_game_data_loaded()
	var upgrades_from_cache_variant = _loaded_game_data.get("upgrades")
	var typed_upgrades: Dictionary[StatsEnums.UpgradeTypes, int] = {}

	if upgrades_from_cache_variant is Dictionary:
		var upgrades_dict: Dictionary = upgrades_from_cache_variant as Dictionary
		for key_variant in upgrades_dict:
			var value_variant = upgrades_dict[key_variant]
			var key_as_int: int = -1
			var valid_key: bool = false

			if typeof(key_variant) == TYPE_INT:
				key_as_int = key_variant
				valid_key = true
			elif key_variant is StatsEnums.UpgradeTypes:
				key_as_int = int(key_variant)
				valid_key = true

			if valid_key and typeof(value_variant) == TYPE_INT:
				if key_as_int in StatsEnums.UpgradeTypes.values():
					typed_upgrades[key_as_int as StatsEnums.UpgradeTypes] = value_variant
				else:
					printerr(
						"Warning: Invalid enum value for upgrade in saved data. Key (int): ",
						key_as_int,
						", Value: ",
						value_variant
					)
			else:
				printerr(
					"Warning: Invalid key/value type for upgrade. Key: ",
					key_variant,
					" (",
					typeof(key_variant),
					"), Value: ",
					value_variant,
					" (",
					typeof(value_variant),
					")"
				)
		if typed_upgrades.is_empty() and not upgrades_dict.is_empty():
			push_warning("Loaded upgrades were present but all entries were invalid or unrecognised. Returning default upgrades.")
			return _get_default_upgrades()
		return typed_upgrades

	push_error("Cached player upgrades are not a Dictionary or missing. Returning defaults.")
	return _get_default_upgrades()

func get_loaded_rounds_won() -> int:
	_ensure_game_data_loaded()
	var rounds_variant = _loaded_game_data.get("rounds_won", 0)
	if typeof(rounds_variant) == TYPE_INT:
		return rounds_variant as int
	push_warning(
		"Cached rounds_won is not an int (type: %s). Returning default 0." % typeof(rounds_variant)
	)
	return 0

func get_loaded_total_rounds_won() -> int:
	_ensure_game_data_loaded()
	var total_rounds_variant = _loaded_game_data.get("total_rounds_won", 0)
	if typeof(total_rounds_variant) == TYPE_INT:
		return total_rounds_variant as int
	push_warning(
		"Cached total_rounds_won is not an int (type: %s). Returning default 0." % typeof(total_rounds_variant)
	)
	return 0

func get_loaded_enemy_encounters() -> Dictionary[String, int]:
	_ensure_game_data_loaded()
	var encounters_variant = _loaded_game_data.get("enemy_encounters")
	if encounters_variant is Dictionary[String, int]:
		return (encounters_variant as Dictionary[String, int]).duplicate()
	elif encounters_variant is Dictionary:
		push_warning("Cached enemy encounters is a generic Dictionary, not Dictionary[String, int]. Attempting to return as is, but structure might be incorrect.")
		var dict_form = encounters_variant as Dictionary[String, int]
		if dict_form:
			return dict_form.duplicate()

	push_error(
		"Cached enemy encounters are not of type Dictionary[String, int] or missing. Returning empty."
	)
	return {} as Dictionary[String, int]

# helper function for getting specific enemy encounter count
func get_enemy_encounter_count(enemy_name: String) -> int:
	enemy_name = enemy_name.to_lower()
	_ensure_game_data_loaded()
	var encounters: Dictionary[String, int] = get_loaded_enemy_encounters()
	if encounters.has(enemy_name):
		return encounters[enemy_name]
	else:
		push_warning("Enemy encounter for '%s' not found. Returning 0." % enemy_name)
		return 0