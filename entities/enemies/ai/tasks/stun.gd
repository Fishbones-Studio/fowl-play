@tool
extends BTAction

## The amount of time to stun the enemy for
@export_range(0.0, 100.0, 0.01) var stun_time: float = 1.0


func _generate_name() -> String:
	return "Stunned for %.1fs" % stun_time


func _enter() -> void:
	agent.is_stunned = true


func _exit() -> void:
	agent.is_stunned = false


func _tick(_delta: float) -> Status:
	if elapsed_time < stun_time:
		return Status.RUNNING
	else:
		return Status.SUCCESS
