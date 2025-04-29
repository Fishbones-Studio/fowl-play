@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"
## How close should the agent be to the desired position to return SUCCESS.
@export var tolerance: float = 2.0
## Desired distance from target.
@export var aggro_distance: float = 20.0
## Duration the enemy will pursue the target.
@export var duration: float


func _generate_name() -> String:
	return "Pursue %s" % [LimboUtility.decorate_var(target_var)]


func _tick(delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var desired_pos: Vector3 = target.global_position

	if _is_at_position(desired_pos):
		return SUCCESS

	if duration and elapsed_time > duration:
		return SUCCESS

	_move_towards_position(desired_pos, delta)
	return RUNNING


func _is_at_position(position: Vector3) -> bool:
	return agent.global_position.distance_to(position) < tolerance


func _move_towards_position(position: Vector3, delta: float) -> void:
	var speed: float = agent.stats.calculate_speed(agent.movement_component.sprint_speed_factor)
	var desired_velocity: Vector3 = agent.global_position.direction_to(position) * speed
	agent.velocity = desired_velocity
