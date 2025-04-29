@tool
extends BTAction

@export var target_var: StringName = &"target"


func _generate_name() -> String:
	return "Pursue ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _tick(delta: float) -> Status:
	agent.apply_gravity(delta)

	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		push_warning("Pursue: Target is not a valid ChickenPlayer (%s: %s)" % [
			LimboUtility.decorate_var(target_var), blackboard.get_var(target_var)])
		return FAILURE

	var target_pos: Vector3 = (target.position - agent.position).normalized() * agent.stats.calculate_speed(agent.movement_component.sprint_speed_factor)

	agent.apply_movement(target_pos)

	return RUNNING
