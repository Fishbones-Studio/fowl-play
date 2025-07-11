@tool
extends BTCondition

## Time interval to check if enemy is stuck.
@export var stuck_interval: float = 1.0
## Minimum distance considered not stuck between last check.
@export var stuck_threshold: float = 2.5

var _last_position: Vector3
var _last_check_time: float = 0.0


func _generate_name() -> String:
	return "Stuck ➜ stuck_interval: %.1fs" % stuck_interval


func _enter() -> void:
	_last_position = agent.global_position
	_last_check_time = 0.0


func _tick(_delta: float) -> Status:
	if elapsed_time < stuck_interval:
		return RUNNING

	if _is_stuck() and not agent.is_stunned:
		return FAILURE

	return SUCCESS


func _is_stuck() -> bool:
	var current_position: Vector3 = agent.global_position
	var moved_distance: float = current_position.distance_to(_last_position)

	_last_position = current_position
	_last_check_time = 0.0

	return true if moved_distance < stuck_threshold else false
