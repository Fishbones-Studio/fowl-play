extends BTAction


func _enter() -> void:
	agent.velocity.x = 0
	agent.velocity.z = 0


func _tick(delta: float) -> Status:
	agent.apply_gravity(delta)

	return SUCCESS
