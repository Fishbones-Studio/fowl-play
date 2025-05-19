@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"
## The amount of offset for the weapon position.
@export var weapon_offset: Vector3
## The maximun angle the weapon is allowed to tilt down.
@export_range(-90, 0 ) var max_down_angle: float = -45.0
## The maximun angle the weapon is allowed to tilt up.
@export_range(0, 90) var max_up_angle: float = 45.0 
## The rotation speed.
@export_range(0.1, 20, 0.1) var rotation_speed: float = 0.1


func _generate_name() -> String:
	return "Rotate weapon towards ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _tick(delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var weapon_pivot: EnemyWeaponController = agent.enemy_weapon_controller
	if not is_instance_valid(weapon_pivot):
		return FAILURE

	var direction: Vector3 = weapon_pivot.global_transform * weapon_offset
	var look_transform: Transform3D = Transform3D().looking_at((target.global_position - direction).normalized())

	var target_rotation: Vector3 = (weapon_pivot.global_transform.basis.inverse() * look_transform.basis).get_euler()
	target_rotation.x = clamp(target_rotation.x, deg_to_rad(max_down_angle), deg_to_rad(max_up_angle))

	weapon_pivot.rotation.x = lerp_angle(weapon_pivot.rotation.x, target_rotation.x, rotation_speed * delta)
	weapon_pivot.rotation.y = lerp_angle(weapon_pivot.rotation.y, target_rotation.y, rotation_speed * delta)

	return SUCCESS
