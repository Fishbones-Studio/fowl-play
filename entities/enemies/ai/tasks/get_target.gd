@tool
extends BTAction

@export var output_var: StringName = &"target"


func _generate_name() -> String:
	return "Get ChickenPlayer ➜ %s" % [LimboUtility.decorate_var(output_var)]


func _tick(_delta: float) -> Status:
	var target: ChickenPlayer = GameManager.chicken_player
	if not is_instance_valid(target):
		push_warning("Get ChickenPlayer: Target is not a valid ChickenPlayer (%s: %s)" % [
			LimboUtility.decorate_var(output_var), blackboard.get_var(output_var)])
		return FAILURE

	blackboard.set_var(output_var, target)
	return SUCCESS
