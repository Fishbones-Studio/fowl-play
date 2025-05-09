extends Ability

@export var descent_velocity: float = -50.0
@export var knockback_force: float = 200
@export var knockback_force_upwards: float = 10

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return stats.attack_multiplier * stats.weight * stats.defense

var _particles_emitted: bool = false

@onready var hit_area: Area3D = $HitArea
@onready var cpu_particles: CPUParticles3D = %CPUParticles3D


func activate() -> void:
	if ability_holder.is_on_floor():
		print("Cannot perform %s while on the ground." % name)
		return

	_toggle_collision_masks(true)
	SignalManager.activate_item_slot.emit(current_ability)

	ability_holder.velocity.x = 0
	ability_holder.velocity.z = 0
	ability_holder.velocity.y = descent_velocity
	
	SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)
	cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	_particles_emitted = false


func _on_hit_area_body_entered(body: Node3D) -> void:
	if body.collision_layer == 2: # if target body is player
		ability_holder._on_weapon_hit_target(ability_holder)
	if body.collision_layer == 4: # if target body is enemy
		SignalManager.weapon_hit_target.emit(body, damage)
	
	_apply_knockback(body)
	
	cpu_particles.emitting = true
	_particles_emitted = true
	
	# resetting vertical velocity
	ability_holder.velocity.y = 0
	
	_toggle_collision_masks(false)
	SignalManager.deactivate_item_slot.emit(current_ability)


func _physics_process(_delta: float) -> void:
	# Handles edge case where character lands without hitting an enemy
	if ability_holder.is_on_floor() and not _particles_emitted and on_cooldown:
		await get_tree().create_timer(0.2).timeout
		cpu_particles.emitting = true
		_particles_emitted = true
		SignalManager.deactivate_item_slot.emit(current_ability)


func _apply_knockback(body: Node3D) -> void:
	if body is CharacterBody3D:
		body.velocity.x = 0
		body.velocity.z = 0

		var dir: Vector3 = ability_holder.global_position.direction_to(body.global_position)

		var knockback: Vector3 = Vector3(
			dir.x * knockback_force,
			dir.y * knockback_force_upwards,
			dir.z * knockback_force
		)
		# Knockback is a bit scuffed due to enemy not having a hurt state implemented.
		body.velocity = knockback * ability_holder.stats.weight


func _toggle_collision_masks(toggle: bool) -> void:
	# Manages collision detection layers:
	# - Enables/disables detection based on owner type

	if ability_holder.collision_layer == 2: # Player
		hit_area.set_collision_mask_value(3, toggle)
	if ability_holder.collision_layer == 4: # Enemy
		hit_area.set_collision_layer_value(2, toggle)

	hit_area.set_collision_mask_value(1, toggle) # World
