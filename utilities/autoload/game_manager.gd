extends Node

signal prosperity_eggs_changed(new_value: int)
signal feathers_of_rebirth_changed(new_value: int)

# Preload default stats once to avoid repeated loading
const DEFAULT_PLAYER_STATS_PATH: String = "uid://bwhuhbesdlyu5"
var _default_player_stats: LivingEntityStats


var chicken_player: ChickenPlayer = null:
	set(value):
		if chicken_player == value:
			return # No change
		chicken_player = value
		# Apply cheats immediately if a player is assigned
		_apply_cheat_settings()


var prosperity_eggs: int:
	set(value):
		if prosperity_eggs == value:
			return
		# print("Setting prosperity eggs to: ", value) # Optional debug print
		prosperity_eggs = value
		# Assuming Inventory and inventory_data are valid singletons/autoloads
		if Inventory and Inventory.inventory_data:
			Inventory.inventory_data.prosperity_eggs = value
		else:
			push_warning("Inventory or Inventory.inventory_data not available.")
		prosperity_eggs_changed.emit(value)


var feathers_of_rebirth: int:
	set(value):
		if feathers_of_rebirth == value:
			return
		feathers_of_rebirth = value
		if Inventory and Inventory.inventory_data:
			Inventory.inventory_data.feathers_of_rebirth = value
		else:
			push_warning("Inventory or Inventory.inventory_data not available.")
		feathers_of_rebirth_changed.emit(value)


## Amount of prosperity eggs earned per round. Gets multiplied by the round number
var arena_round_reward: int = 50
## Amount of prosperity eggs earned for completing the arena (aka the final round)
var arena_completion_reward: int = 200

var current_round: int = 1:
	set(value):
		if current_round == value:
			return
		# If the round progresses, add more prosperity eggs
		if value > current_round:
			# Use the setter to ensure signal emission and inventory update
			self.prosperity_eggs += arena_round_reward * value
		current_round = value


# Cheat variables
var infinite_health: bool = false:
	set(value):
		if infinite_health == value:
			return # No change
		infinite_health = value
		_apply_cheat_settings() # Re-apply settings when toggle changes


var infinite_damage: bool = false:
	set(value):
		if infinite_damage == value:
			return # No change
		infinite_damage = value
		_apply_cheat_settings() # Re-apply settings when toggle changes


func _ready() -> void:
	# Load default stats during initialization
	# TODO: once permanemt upgrades have been implemented, rewrite this
	_default_player_stats = ResourceLoader.load(DEFAULT_PLAYER_STATS_PATH).duplicate()
	if not _default_player_stats:
		push_error(
			"Failed to load default player stats from %s"
			% DEFAULT_PLAYER_STATS_PATH
		)


## Applies or removes cheat effects based on current toggle states.
func _apply_cheat_settings() -> void:
	# Only apply if we have a valid player instance
	if not is_instance_valid(chicken_player):
		return

	# Ensure default stats are loaded before proceeding
	if not _default_player_stats:
		push_warning(
			"Cannot apply cheat settings: Default player stats not loaded."
		)
		return

	# Health Cheat
	if infinite_health:
		print("Setting infinite health")
		chicken_player.stats.max_health = INF
		chicken_player.stats.current_health = INF
		# Using a very large number for regen instead of INF, since INF is a float
		chicken_player.stats.health_regen = 9223372036854775807 # Max int
	else:
		print("Restoring health stats from default resource for health")
		# Restore health stats from the loaded default resource
		chicken_player.stats.max_health = _default_player_stats.max_health
		# Restore health, the current_health has a clamp in setter
		chicken_player.stats.current_health = chicken_player.stats.current_health
		chicken_player.stats.health_regen = _default_player_stats.health_regen

	# Damage Cheats
	if infinite_damage:
		print("Setting infinite damage")
		chicken_player.stats.attack = INF
	else:
		print("Restoring damage stats from default resource for damage")
		# Restore damage stats from the loaded default resource
		chicken_player.stats.attack = _default_player_stats.attack


func reset_game() -> void:
	# Use the setter for prosperity_eggs to ensure signals/updates happen
	prosperity_eggs = clamp(
		(100 + current_round * int(arena_round_reward / 2.0)), 125, 200
	)
	if Inventory:
		Inventory.reset_inventory()
	else:
		push_warning("Inventory not available for reset.")
