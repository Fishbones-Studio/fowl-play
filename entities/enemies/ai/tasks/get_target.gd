@tool
extends BTAction

## Blackboard variable in which the task will store the acquired node.
@export var target_var: StringName = &"target"


func _generate_name() -> String:
	return "Get ChickenPlayer ➜ %s" % [
		LimboUtility.decorate_var(target_var)
		]


func _tick(_delta: float) -> Status:
	var target: ChickenPlayer = GameManager.chicken_player
	if is_instance_valid(target):
		blackboard.set_var(target_var, target)
		return SUCCESS
	return FAILURE
