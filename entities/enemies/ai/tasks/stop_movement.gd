@tool 
extends BTAction

## The minimum wait time in seconds
@export_range(0.0, 5.0, 0.1) var min_wait_time: float = 0.0
## The maximum wait time in seconds
@export_range(0.0, 5.0, 0.1) var max_wait_time: float = 0.0

var _target_wait_time: float = 0.0


func _generate_name() -> String:
	var name: String = "Stop Movement"

	if min_wait_time == max_wait_time:
		name += " %.1fs" % min_wait_time
	else:
		name += " %.1f-%.1fs" % [min_wait_time, max_wait_time]
	
	return name


func _enter() -> void:
	_target_wait_time = randf_range(min_wait_time, max_wait_time)
	agent.velocity = Vector3.ZERO


func _tick(delta: float) -> Status:
	# Keep velocity at zero while waiting
	agent.velocity = Vector3.ZERO

	if elapsed_time >= _target_wait_time:
		return SUCCESS
	return RUNNING


func _exit() -> void:
	_target_wait_time = 0.0
