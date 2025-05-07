extends BaseRangedCombatState

@export var projectile_scene: PackedScene = preload("uid://d1jf4shjaqq4n")
@export var attack_origin: Node3D
@export var launch_speed: float = 20.0
@export var launch_angle_degrees: float = 30.0

func enter(_previous_state, _info: Dictionary = {}) -> void:
	if not weapon or not weapon.current_weapon or not weapon.entity_stats:
		push_error("SlingshotAttackState: Weapon, current_weapon, or entity_stats not properly set up!")
		if transition_signal:
			transition_signal.emit(WeaponEnums.WeaponState.IDLE, {})
		return

	if weapon.entity_stats.is_player:
		SignalManager.cooldown_item_slot.emit(
			weapon.current_weapon,
			weapon.current_weapon.windup_time,
			false
		)

func _fire_projectile() -> void:
	if not projectile_scene:
		push_error("SlingshotAttackState: Projectile scene not set!")
		return
	if not attack_origin:
		push_error("SlingshotAttackState: Attack origin not set!")
		return

	var projectile_instance: Node = projectile_scene.instantiate()
	if not projectile_instance is RigidBody3D:
		push_error("SlingshotAttackState: Projectile scene root must be a RigidBody3D.")
		projectile_instance.queue_free()
		return

	get_tree().current_scene.add_child(projectile_instance)
	projectile_instance.global_position = attack_origin.global_position
	projectile_instance.global_rotation = attack_origin.global_rotation

	var forward_dir: Vector3 = -attack_origin.global_transform.basis.z
	var right_dir: Vector3 = attack_origin.global_transform.basis.x
	var launch_angle_rad: float = deg_to_rad(launch_angle_degrees)
	var launch_direction: Vector3 = forward_dir.rotated(right_dir, launch_angle_rad).normalized()

	projectile_instance.linear_velocity = launch_direction * launch_speed
	projectile_instance.angular_velocity = Vector3(
		randf_range(-1, 1),
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized() * PI

	if projectile_instance.has_method("setup_projectile"):
		projectile_instance.setup_projectile(
			weapon.entity_stats,
			weapon.current_weapon.damage
		)
	else:
		push_error("Provided projectile cannot be set up")

func exit() -> void:
	_fire_projectile()
