@tool
extends BTCondition

@export var target_var: StringName = &"target" # Blackboard key
@export_range(0.0, 100.0, 0.1) var horizontal_threshold: float = 5.0 # Max horizontal dist
@export_range(0.0, 100.0, 0.1) var vertical_threshold: float = 3.0   # Max vertical dist
@export var require_descent: bool = false                            # Only when falling

func _generate_name() -> String:
	return "Air & Close ➜ H≤%.1f, V≤%.1f" % [
		horizontal_threshold, vertical_threshold
	]

func _tick(_delta: float) -> Status:
	var target = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	# Must be in the air (and optionally descending)
	var in_air = not agent.is_on_floor()
	if require_descent and agent.velocity.y >= 0.0:
		in_air = false

	# Compute offset
	var offset = target.global_position - agent.global_position

	# Horizontal distance = sqrt(dx^2 + dz^2)
	var horizontal_dist = Vector3(offset.x, 0.0, offset.z).length()
	var horz_ok = horizontal_dist <= horizontal_threshold

	# Vertical distance
	var vertical_dist = abs(offset.y)
	var vert_ok = vertical_dist <= vertical_threshold

	# Debug print
	print(
		"[BTCondition] in_air: %s, horizontal_dist: %.2f (ok: %s), vertical_dist: %.2f (ok: %s)" % [
			str(in_air),
			horizontal_dist,
			str(horz_ok),
			vertical_dist,
			str(vert_ok)
		]
	)

	return SUCCESS if (in_air and horz_ok and vert_ok) else FAILURE
