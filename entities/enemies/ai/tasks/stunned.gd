@tool
extends BTCondition


func _generate_name() -> String:
	return "Stunned ➜ self"


func _tick(_delta: float) -> Status:
	if agent.is_stunned:
		return FAILURE

	return SUCCESS
