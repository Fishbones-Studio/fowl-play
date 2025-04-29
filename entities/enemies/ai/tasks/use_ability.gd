@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"


func _tick(delta: float) -> Status:
	agent.enemy_ability_controller.try_activate_ability()
	return SUCCESS
