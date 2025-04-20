extends Ability

@export_range(0, 100, 1) var health_consumption: float = 25.0
@export var damage_duration: float = 2.0
@export var damage_interval: float = 0.2

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return stats.attack_multiplier * (stats.max_health / stats.current_health * stats.defense) + stats.max_health

@onready var hit_area: Area3D = $HitArea
@onready var cpu_particles: CPUParticles3D = %CPUParticles3D


func activate() -> void:
	if not ability_holder.is_on_floor():
		return

	cpu_particles.emitting = true

	_toggle_collision_masks(true)
	SignalManager.activate_item_slot.emit(current_ability)

	# Consumes a percentage of the holder's max health when activating the ability
	# If the current HP is not sufficient, reduces HP to 1 (can't drop to 0 or below)
	ability_holder.stats.current_health -= min(ability_holder.stats.max_health * (health_consumption / 100.0), ability_holder.stats.current_health - 1.0)

	SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)
	cooldown_timer.start()


func _apply_burn(body: Node3D) -> void:
	if body is CharacterBody3D:
		# Get the amount of ticks the burn applies, rounded down
		var burn_tick_count: int = floor(damage_duration / damage_interval)
		var burn_damage: float = damage / burn_tick_count

		for i in range(burn_tick_count):
			await get_tree().create_timer(damage_interval).timeout

			# If body doesn't exist, don't apply damage
			if not is_instance_valid(body):
				break

			if body.collision_layer == 2: # Player
				ability_holder._on_weapon_hit_target(ability_holder)
			if body.collision_layer == 4: # Enemy
				SignalManager.weapon_hit_target.emit(body, burn_damage)


func _toggle_collision_masks(toggle: bool) -> void:
	if ability_holder.collision_layer == 2: # Player
		hit_area.set_collision_mask_value(3, toggle)
	if ability_holder.collision_layer == 4: # Enemy
		hit_area.set_collision_layer_value(2, toggle)

	hit_area.set_collision_mask_value(1, toggle) # World


func _on_hit_area_body_entered(body: Node3D) -> void:
	_apply_burn(body)

	_toggle_collision_masks(false)
	SignalManager.deactivate_item_slot.emit(current_ability)
