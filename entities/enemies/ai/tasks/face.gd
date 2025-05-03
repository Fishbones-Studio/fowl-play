@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"
## The enemy rotation speed.
@export var rotation_speed: float = 6.0
## Angle threshold to return SUCCESS in degrees.
@export var angle_threshold: float = 25.0
## How long to perform this task (in seconds).
@export var duration: float


func _generate_name() -> String:
	return "Face ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _tick(delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var desired_direction: Vector3 = agent.global_position.direction_to(target.global_position)

	if _is_at_direction(desired_direction):
		return SUCCESS

	if duration and elapsed_time > duration:
		return SUCCESS

	_rotate_toward_direction(desired_direction, delta)
	return RUNNING


func _is_at_direction(direction: Vector3) -> bool:
	var forwad_direction: Vector3 = -agent.global_basis.z.normalized()
	var angle: float = rad_to_deg(forwad_direction.angle_to(direction))

	return angle <= angle_threshold


func _rotate_toward_direction(direction: Vector3, delta: float) -> void:
	var target_angle: float = atan2(-direction.x, -direction.z) # Calculate the angle to the target direction

	# Lerp the angle to smoothly rotate towards the target direction
	agent.rotation.y = lerp_angle(agent.rotation.y, target_angle, rotation_speed * delta)
