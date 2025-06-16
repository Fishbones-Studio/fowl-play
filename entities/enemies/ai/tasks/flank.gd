@tool
extends BTAction

## Blackboard variable that stores our target
@export var target_var: StringName = &"target"
## Distance behind target to teleport
@export var flank_distance: float = 2.0
## Vertical offset to prevent ground clipping
@export var vertical_offset: float = 0.0
## Radius to check for clear space
@export_range(0.1, 5.0, 0.1) var clearance_radius: float = 1.0
## Time to wait before executing action
@export var telegraph_timer: float = 1.0
## Make enemy invisible while flanking
@export var invisible_flank: bool = true


var _telegraph_instance: Variant
var _flank_position: Vector3
var _area: Area3D = null

# Display a customized name (requires @tool).
func _generate_name() -> String:
	var name: String = "Flank ➜ "

	if target_var:
		name += LimboUtility.decorate_var(target_var) + "  "

	if flank_distance != 2.0:
		name += "flank_distance: %.1f  " % flank_distance

	if vertical_offset > 0:
		name += "vertical_offset: %.1f  " % vertical_offset

	if clearance_radius != 1.0:
		name += "clearance_radius: %.1f" % clearance_radius

	return name if name != "Flank ➜ " else "Flank"


func _tick(_delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	if not _flank_position:
		_flank_position = _get_safe_flank_position(target)

		if _flank_position == Vector3.INF:
			return FAILURE

	if not _telegraph_instance: 
		_telegraph_instance = _create_telegraph(_flank_position)

	while elapsed_time < telegraph_timer:
		return RUNNING

	# Omae wa mou shindeiru
	agent.global_position = _flank_position
	agent.velocity = Vector3.ZERO
	agent.look_at(target.global_position)

	_flank_position = Vector3.ZERO

	agent.remove_child(_telegraph_instance)
	_telegraph_instance.queue_free()
	_telegraph_instance = null

	agent.remove_child(_area)
	_area.queue_free()
	_area = null

	return SUCCESS


func _get_safe_flank_position(target: ChickenPlayer) -> Vector3:
	var base_dir: Vector3 = -target.global_transform.basis.z.normalized()
	var test_angles: Array[float] = [180, 90, -90, 45, -45, 0]  # Test multiple approach angles

	test_angles.shuffle()

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

	var shape: SphereShape3D = SphereShape3D.new()
	shape.radius = clearance_radius

	var collission_shape: CollisionShape3D = CollisionShape3D.new()
	collission_shape.shape = shape

	_area = Area3D.new()
	_area.add_child(collission_shape)
	_area.collision_mask = agent.collision_mask

	agent.add_child(_area)
	_area.global_position = position

	return _area.get_overlapping_bodies().is_empty()


# Whack
func _create_telegraph(telegraph_position: Vector3) -> Variant:
	var resource: PackedScene = preload("uid://bi7ih1it2v747")
	var instance: GPUParticles3D = resource.instantiate()
	var mesh: Mesh = instance.draw_pass_1

	if mesh is SphereMesh:
		var shape: Shape3D = agent.shape.shape
		if shape is SphereShape3D:
			mesh.radius = shape.radius
			mesh.height = shape.height
		if shape is CapsuleShape3D:
			mesh.radius = shape.radius
			mesh.height = shape.radius * 2
		if shape is BoxShape3D:
			mesh.radius = shape.size.x / 2
			mesh.height = shape.size.y

	instance.lifetime = telegraph_timer
	agent.add_child(instance)
	instance.global_position = Vector3(
		telegraph_position.x,
		telegraph_position.y,
		telegraph_position.z,
	)
	printerr(instance.global_position)
	instance.emitting = true

	return instance
