@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"
## How close should the agent be to the desired position to return SUCCESS.
@export var tolerance: float = 2.0
## Desired distance from target.
@export var aggro_distance: float = 20.0
## Pursuit speed factor.
@export var speed_factor: float = 0.0
## Duration the enemy will pursue the target.
@export var duration: float
## Time interval to check if enemy is stuck.
@export var stuck_interval: float = 1.0
## Minimum distance considered not stuck between last check.
@export var stuck_threshold: float = 2.5

var _last_position: Vector3
var _last_check_time: float = 0.0


func _generate_name() -> String:
	return "Pursue ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _enter() -> void:
	_last_position = agent.global_position
	_last_check_time = 0.0


func _tick(delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	_last_check_time += delta

	var desired_pos: Vector3 = target.global_position

	if _is_at_position(desired_pos):
		return SUCCESS

	if bool(duration) and elapsed_time > duration:
		return SUCCESS

	if _is_stuck():
		return FAILURE

	_move_towards_position(desired_pos, delta)
	return RUNNING


func _is_at_position(position: Vector3) -> bool:
	return agent.global_position.distance_to(position) < tolerance


func _move_towards_position(position: Vector3, delta: float) -> void:
	var speed: float = speed_factor if speed_factor > 0.0 else agent.stats.calculate_speed(agent.movement_component.sprint_speed_factor)
	var desired_velocity: Vector3 = agent.global_position.direction_to(position) * speed

	agent.velocity.x = desired_velocity.x
	agent.velocity.z = desired_velocity.z


func _is_stuck() -> bool:
	if _last_check_time < stuck_interval:
		return false

	var current_position: Vector3 = agent.global_position
	var moved_distance: float = current_position.distance_to(_last_position)

	_last_position = current_position
	_last_check_time = 0.0

	print("aaaaaaaaaaa Distance moved while in pursue: %.2f" % moved_distance)

	return moved_distance < stuck_threshold
