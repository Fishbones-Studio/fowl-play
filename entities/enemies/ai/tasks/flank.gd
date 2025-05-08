@tool
extends BTAction

## Blackboard variable that stores our target
@export var target_var: StringName = &"target"
## Distance behind target to teleport
@export var flank_distance: float = 2.0
## Vertical offset to prevent ground clipping
@export var vertical_offset: float = 0.0
## Radius to check for clear space
@export_range(0.1, 5.0, 0.1) var clearance_radius: float = 0.5


# Display a customized name (requires @tool).
func _generate_name() -> String:
	var name: String = "Flank ➜ "

	if target_var:
		name += LimboUtility.decorate_var(target_var) + "  "

	if flank_distance != 2.0:
		name += "flank_distance: %.1f  " % flank_distance

	if vertical_offset > 0:
		name += "vertical_offset: %.1f  " % vertical_offset

	if clearance_radius != 0.5:
		name += "clearance_radius: %.1f" % clearance_radius

	return name if name != "Flank ➜ " else "Flank"


func _tick(_delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var flank_position: Vector3 = _get_safe_flank_position(target)
	if flank_position == Vector3.INF:
		return FAILURE

	# Omae wa mou shindeiru
	agent.global_position = flank_position
	agent.velocity = Vector3.ZERO
	agent.look_at(target.global_position)

	return SUCCESS


func _get_safe_flank_position(target: ChickenPlayer) -> Vector3:
	var base_dir: Vector3 = -target.global_transform.basis.z.normalized()
	var test_angles: Array[float] = [180, 90, -90, 45, -45, 0]  # Test multiple approach angles

	for angle in test_angles:
		var rotated_dir: Vector3 = base_dir.rotated(Vector3.UP, deg_to_rad(angle))
		var test_pos: Vector3 = target.global_position + (rotated_dir * flank_distance)
		test_pos.y += vertical_offset

		if _is_position_clear(test_pos):
			return test_pos
	
	return Vector3.INF


func _is_position_clear(position: Vector3) -> bool:
	if is_equal_approx(clearance_radius, 0.0):
		push_error("clearance_radius must be > 0 (current: %f)" % clearance_radius)
		return false

	# Create temporary shape for testing
	var shape: SphereShape3D = SphereShape3D.new()
	shape.radius = clearance_radius

	# Configure query parameters
	var params: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	params.transform = Transform3D(Basis(), position)
	params.shape = shape
	params.collision_mask = agent.collision_mask

	# Perform query
	var space_state: PhysicsDirectSpaceState3D = agent.get_world_3d().direct_space_state
	var results: Array[Dictionary] = space_state.intersect_shape(params, 1)

	return results.is_empty()
