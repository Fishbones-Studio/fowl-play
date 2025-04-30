@tool
extends BTAction

## Blackboard variable that stores our target
@export var target_var: StringName = &"target"
## Desired distance from target to maintain
@export var retreat_distance: float = 20.0
## Retreat speed factor
@export var speed_factor: float = 0.0
## Rotation speed
@export var rotation_speed: float = 6.0
## Duration the enemy will retreat
@export var duration: float = 0.0


func _generate_name() -> String:
	var name: String = "Retreat ➜ "

	if retreat_distance != 20.0:
		name += "retreat_distance: %.1f  " % retreat_distance

	if not is_equal_approx(speed_factor, 1.0):
		name += "speed_factor: %.1f  " % speed_factor

	if rotation_speed != 6.0:
		name += "rotation_speed: %.1f" % rotation_speed

	if bool(duration):
		name += "duration: %.1f" % duration

	return name if name != "Retreat ➜ " else "Retreat"


func _tick(delta: float) -> Status:
	var target = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var retreat_direction: Vector3 = target.global_position.direction_to(agent.global_position)
	var current_distance: float = target.global_position.distance_to(agent.global_position)

	if current_distance > retreat_distance:
		return SUCCESS

	if bool(duration) and elapsed_time > duration:
		return SUCCESS

	_retreat(retreat_direction, delta)
	return RUNNING


func _retreat(direction: Vector3, delta: float) -> void:
	if direction.length() > 0:
		var target_rotation = Basis.looking_at(direction, Vector3.UP)
		agent.transform.basis = agent.transform.basis.slerp(target_rotation, rotation_speed * delta)

	var speed: float = speed_factor if speed_factor > 0.0 else agent.stats.calculate_speed(agent.movement_component.sprint_speed_factor)

	agent.velocity.x = direction.x * speed
	agent.velocity.z = direction.z * speed
