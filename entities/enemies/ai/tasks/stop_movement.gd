extends BTAction


func _tick(_delta: float) -> Status:
	agent.velocity = Vector3.ZERO
	if agent.velocity == Vector3.ZERO:
		return SUCCESS
	return RUNNING
