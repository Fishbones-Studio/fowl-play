extends Ability

@export var descent_velocity: float = -50.0
@export var knockback_force: float = 2.0
@export var knockback_force_upwards: float = 1.5
@export var damage_scaler: int = 9

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return damage_scaler * stats.weight

var _hit_bodies: Array = []
var _particles_emitted: bool = false

@onready var hit_area: Area3D = $HitArea
@onready var gpu_particles: GPUParticles3D = %GPUParticles3D


func activate() -> void:
	if ability_holder.is_on_floor():
		print("Cannot perform %s while on the ground." % name)
		return

	_hit_bodies.clear()

	_toggle_collision_masks(true, hit_area)

	ability_holder.velocity.x = 0
	ability_holder.velocity.z = 0
	ability_holder.velocity.y = descent_velocity

	if ability_holder is ChickenPlayer:
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	_particles_emitted = false


func _physics_process(_delta: float) -> void:
	if ability_holder.is_on_floor() and not _particles_emitted and on_cooldown:
		_pound()


func _pound() -> void:
	gpu_particles.emitting = true

	# Make it deal two instances of damage
	await get_tree().create_timer(0.2).timeout

	for body in hit_area.get_overlapping_bodies():
		if body in _hit_bodies:
			continue

		if body.collision_layer in [2, 4]:  # Player or Enemy
			SignalManager.weapon_hit_target.emit(
					body,
					damage,
					DamageEnums.DamageTypes.NORMAL,
					{
						"knockback": _calculate_knockback(body),
					},
				)
			_hit_bodies.append(body)

	_particles_emitted = true

	# resetting vertical velocity
	ability_holder.velocity.y = 0

	_hit_bodies.clear()
	_toggle_collision_masks(false, hit_area)


func _calculate_knockback(body: Node3D) -> Vector3:
	if body is CharacterBody3D:
		var dir: Vector3 = ability_holder.global_position.direction_to(body.global_position)

		var knockback: Vector3 = Vector3(
			sign(dir.x) * knockback_force,
			max(1, sign(dir.y)) * knockback_force_upwards,
			sign(dir.z) * knockback_force,
		)
		var knockback_y: float = knockback.y * max(ability_holder.stats.weight, 7)

		return Vector3(
				knockback.x,
				knockback_y if is_zero_approx(body.velocity.y) else knockback_y / 2.5,
				knockback.z,
				)

	return Vector3.ZERO
