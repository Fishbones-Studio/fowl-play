@tool
extends BTAction

## Blackboard variable that stores our target
@export var targe_var: StringName = &"target"
## Distance behind target to teleport
@export var flank_distance: float = 2.0


func _generate_name() -> String:
	return "Flank %s" % [LimboUtility.decorate_var(targe_var)]


func _tick(_delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(targe_var)
	if not is_instance_valid(target):
		return FAILURE

	# Calculate flank position
	var flank_position: Vector3 = _calculate_flank_position(target)

	# Teleport agent
	agent.global_position = flank_position
	agent.velocity = Vector3.ZERO  # Reset momentum
	agent.look_at(target.global_position)

	return SUCCESS


func _calculate_flank_position(target: ChickenPlayer) -> Vector3:
	# Get target's forward vector (assuming -Z is forward)
	var flank_direction: Vector3 = -target.global_transform.basis.z.normalized()

	# Calculate position behind target
	return target.global_position + (flank_direction * flank_distance)
