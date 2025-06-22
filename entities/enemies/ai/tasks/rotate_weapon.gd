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


func _generate_name() -> String:
	return "Rotate Weapon ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _tick(_delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var weapon_pivot: EnemyWeaponController = agent.enemy_weapon_controller
	if not is_instance_valid(weapon_pivot):
		return FAILURE

	weapon_pivot.look_at(target.global_position + weapon_offset)
	weapon_pivot.rotation.x = clamp(weapon_pivot.rotation.x, deg_to_rad(max_down_angle), deg_to_rad(max_up_angle))
	weapon_pivot.rotation.z = 0.0

	return SUCCESS
