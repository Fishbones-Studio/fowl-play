@tool
extends BTCondition


func _generate_name() -> String:
	return "IsHurt ➜ Agent"


func _tick(_delta: float) -> Status:
	if agent.hurt_ticks.size() > 0:
		agent.hurt_ticks.pop_front()
		return SUCCESS
	return FAILURE
