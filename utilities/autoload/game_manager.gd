extends Node

signal prosperity_eggs_changed(new_value: int)
signal feathers_of_rebirth_changed(new_value: int)
signal player_stats_updated(new_stats: LivingEntityStats)
signal chicken_player_set()


var chicken_player: ChickenPlayer = null:
	set(value):
		if chicken_player == value:
			return # No change
		chicken_player = value
		print("GameManager.chicken_player set to:", value)
		if value != null:
			chicken_player_set.emit()
		
var current_enemy: Enemy

var prosperity_eggs: int:
	set(value):
		if prosperity_eggs == value:
			return
		prosperity_eggs = value
		prosperity_eggs_changed.emit(value)


var feathers_of_rebirth: int:
	set(value):
		if feathers_of_rebirth == value:
			return
		feathers_of_rebirth = value
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
		if chicken_player:
			chicken_player.stats = apply_cheat_settings(chicken_player.stats, SaveManager.get_loaded_player_stats()) # Re-apply settings when toggle changes
		else:
			push_warning("Chicken player not set, cannot apply health cheat settings.")


var infinite_damage: bool = false:
	set(value):
		if infinite_damage == value:
			return # No change
		infinite_damage = value
		if chicken_player:
			chicken_player.stats = apply_cheat_settings(chicken_player.stats, SaveManager.get_loaded_player_stats()) # Re-apply settings when toggle changes
		else:
			push_warning("Chicken player not set, cannot apply damage cheat settings.")


## Applies or removes cheat effects based on current toggle states.
func apply_cheat_settings(stats : LivingEntityStats, default_stats : LivingEntityStats, apply_only_when_on := false) -> LivingEntityStats:
	if apply_only_when_on && !(infinite_health or infinite_damage):
		print("Cheat settings not applied, both cheats are off.")
		return stats
	
	if default_stats == null:
		push_error("Apply cheats: Failed to load default player stats from SaveManager!")
		return stats

	# Health Cheat
	if infinite_health:
		print("Setting infinite health")
		stats.max_health = INF
		stats.current_health = INF
		# Using a very large number for regen instead of INF, since INF is a float
		stats.health_regen = 9223372036854775807 # Max int
	else:
		print("Restoring health stats from default resource for health")
		# Restore health stats from the loaded default resource
		stats.max_health = default_stats.max_health
		# Restore health, the current_health has a clamp in setter
		stats.current_health = default_stats.max_health
		stats.health_regen = default_stats.health_regen

	# Damage Cheats
	if infinite_damage:
		print("Setting infinite damage")
		stats.attack = INF
	else:
		print("Restoring damage stats from default resource for damage")
		# Restore damage stats from the loaded default resource
		stats.attack = default_stats.attack
		
	player_stats_updated.emit(stats) # Emit signal to update player stats in the game
	return stats


func reset_game() -> void:
	# Use the setter for prosperity_eggs to ensure signals/updates happen
	prosperity_eggs = clamp(
		(100 + current_round * int(arena_round_reward / 2.0)), 300, 300
	)
	SaveManager.reset_game()
	if Inventory:
		Inventory.reset_inventory()
	else:
		push_warning("Inventory not available for reset.")
