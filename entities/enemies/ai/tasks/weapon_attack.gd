@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"


func _generate_name() -> String:
	return "Attack %s with weapon" % [LimboUtility.decorate_var(target_var)]


func _tick(_delta: float) -> Status:
	if agent.enemy_weapon_controller.use_weapon():
		return SUCCESS
	return FAILURE
