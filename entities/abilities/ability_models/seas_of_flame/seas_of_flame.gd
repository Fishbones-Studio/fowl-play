extends Ability

## The percentage of health the user loses upon activating Seas of Flame
@export_range(0, 100, 1) var health_consumption: int = 20
## The total duration over which the damage is applied
@export var damage_duration: float = 2.0
## The interval between each instance of damage applied
@export var damage_interval: float = 0.2
## The maximum damage multiplier applied at the start of the burn effect
@export var peak_burn_modifier: int = 175
@export var minimum_damage : float = 40

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return max(minimum_damage, (stats.max_health / stats.current_health) * (1.0 + (stats.attack / 100)))

var _attack_duration: float = 0.0
var _hit_bodies: Array = []

@onready var hit_area: Area3D = $HitArea
@onready var cpu_particles: CPUParticles3D = %CPUParticles3D


func activate() -> void:
	if not ability_holder.is_on_floor():
		return

	_attack_duration = cpu_particles.lifetime
	_hit_bodies.clear()

	cpu_particles.emitting = true

	_toggle_collision_masks(true, hit_area)

	# Consumes a percentage of the holder's max health when activating the ability
	# If the current HP is not sufficient, reduces HP to 1 (can't drop to 0 or below)
	ability_holder.stats.current_health -= min(ability_holder.stats.max_health * (health_consumption / 100.0), ability_holder.stats.current_health - 1.0)

	if ability_holder is ChickenPlayer:
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _physics_process(delta: float) -> void:
	_attack_duration -= delta

	if _attack_duration <= 0:
		_attack_duration = 0.0
		_toggle_collision_masks(false, hit_area)

	for body in hit_area.get_overlapping_bodies():
		if body in _hit_bodies:
			continue

		if body.collision_layer == 2 or body.collision_layer == 4:  # Player or Enemy
			_apply_burn(body)
			_hit_bodies.append(body)


func _apply_burn(body: Node3D) -> void:
	if body is CharacterBody3D:
		# Get the amount of ticks the burn applies, rounded down and make sure the count isn't below 1
		var burn_tick_count: int = max(1, floor(damage_duration / damage_interval))

		for i in range(burn_tick_count):
			await get_tree().create_timer(damage_interval).timeout

			# If body doesn't exist, don't apply damage
			if not is_instance_valid(body):
				break

			# Gradually decreasing the burn damage from peak to default across the damage tick count
			var weight: float = i as float / (burn_tick_count - 1)
			var burn_damage: float = lerp(peak_burn_modifier / 100.0, 1.0, weight) * (damage / burn_tick_count)

			if body.collision_layer == 2: # Player
				SignalManager.weapon_hit_target.emit(body, burn_damage, DamageEnums.DamageTypes.NORMAL)
			if body.collision_layer == 4: # Enemy
				SignalManager.weapon_hit_target.emit(body, burn_damage, DamageEnums.DamageTypes.NORMAL)
