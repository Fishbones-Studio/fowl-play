@tool
extends BTAction

@export var target_var: StringName = &"target"
@export var rotation_speed: float = 5.0
@export var min_angle: float = 0.5


func _generate_name() -> String:
	return "Face ChickenPlayer ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _tick(delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		push_warning("Face ChickenPlayer: Target is not a valid ChickenPlayer (%s: %s)" % [
			LimboUtility.decorate_var(target_var), blackboard.get_var(target_var)])
		return FAILURE

	var direction: Vector3 = agent.global_position.direction_to(target.global_position)

	var target_angle: float = atan2(-direction.x, -direction.z)
	var current_angle: float = agent.rotation.y

	agent.rotation.y = lerp_angle(current_angle, target_angle, rotation_speed * delta)

	if abs(current_angle - target_angle) < min_angle:
		return SUCCESS

	return RUNNING
