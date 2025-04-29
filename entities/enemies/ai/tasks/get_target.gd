@tool
extends BTAction

## Blackboard variable in which the task will store the acquired node.
@export var output_var: StringName = &"target"


func _tick(_delta: float) -> Status:
	var target: ChickenPlayer = GameManager.chicken_player
	if is_instance_valid(target):
		blackboard.set_var(output_var, target)
		return SUCCESS
	return FAILURE
