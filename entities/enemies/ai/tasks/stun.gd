@tool
extends BTAction

## The amount of time to stun the enemy for
@export_range(0.0, 100.0, 0.01) var stun_time : float = 1.0

var _timer : float = 0.0

func _generate_name() -> String:
	return "Stunned for %2.fs" % stun_time

func _enter() -> void:
	agent.is_stunned = true
	_timer = 0.0

func _exit() -> void:
	agent.is_stunned = false

func _tick(_delta: float) -> Status:
	_timer += _delta
	if _timer < stun_time:
		return Status.RUNNING
	else:
		return Status.SUCCESS
