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
@export var telegraph_start_timer: float = 0.5
## Time to wait before executing action
@export var telegraph_end_timer: float = 1.0
## Make enemy invisible while flanking
@export var invisible_flank: bool = true
## Flank immediately, telegraph timer is negated
@export var immediate_flank: bool = false
## Telegraph that appears before agent disappears
@export var first_telegraph: bool = true

var _telegraph_instance: Variant
var _flank_position: Vector3
var _area: Area3D = null
var _flank_started: bool = false
var _reappear_time: float = 1048576
var _final_telegraphinc_finished: bool = false


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


func _enter() -> void:
	if _flank_started:
		return

	if immediate_flank:
		_flank_started = true
		return

	if first_telegraph:
		_create_telegraph(agent.global_position, true)


func _tick(_delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	if not _flank_started and not immediate_flank:
		if first_telegraph:
			# Only disappear after first telegraph finishes. Sync with telegraph bubble scale.
			if elapsed_time > telegraph_start_timer * 0.4:
				if agent.visible: agent.visible = false
			return RUNNING
		else:
			# Immediate disappear if no first telegraph
			if agent.visible: agent.visible = false
			_flank_started = true
			return RUNNING

	if not _flank_position:
		_flank_position = _get_safe_flank_position(target)
		if _flank_position == Vector3.INF:
			return FAILURE

	if immediate_flank:
		return SUCCESS

	if not _telegraph_instance: 
		_create_telegraph(_flank_position)

	if elapsed_time > _reappear_time and not agent.visible:
		agent.visible = true

	if elapsed_time >= telegraph_end_timer + telegraph_start_timer:
		if _final_telegraphinc_finished:
			return SUCCESS

	agent.global_position = _flank_position
	agent.velocity = Vector3.ZERO
	return RUNNING


func _exit() -> void:
	agent.visible = true
	agent.global_position = _flank_position
	agent.velocity = Vector3.ZERO

	_flank_position = Vector3.ZERO
	_reappear_time = 1048576
	_final_telegraphinc_finished = false
	_flank_started = false


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


# Abosolute Cine- Whack
func _create_telegraph(telegraph_position: Vector3, reverse: bool = false) -> void:
	var resource: PackedScene = preload("uid://bi7ih1it2v747")
	var instance: GPUParticles3D = resource.instantiate().duplicate()
	var mesh: Mesh = instance.draw_pass_1
	var material: ParticleProcessMaterial = instance.process_material.duplicate()
	var original_scale_min: float = material.scale_min

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

	material.scale_min = original_scale_min * 2.0
	instance.process_material = material

	agent.get_parent().add_child(instance)
	instance.global_position = Vector3(
		telegraph_position.x,
		telegraph_position.y + vertical_offset if not reverse else \
		telegraph_position.y + telegraph_position.y / 2,
		telegraph_position.z,
	)

	if reverse:
		instance.amount = 1
		instance.lifetime = telegraph_start_timer
	else:
		instance.lifetime = telegraph_end_timer
		_reappear_time = instance.lifetime + telegraph_start_timer
		agent.global_position = telegraph_position

	instance.finished.connect(_on_telegraphing_finished.bind(reverse))
	instance.emitting = true

	_telegraph_instance = instance


func _on_telegraphing_finished(reverse: bool = false) -> void:
	if _telegraph_instance:
		agent.get_parent().remove_child(_telegraph_instance)
		_telegraph_instance.queue_free()
		_telegraph_instance = null

	if _area:
		agent.remove_child(_area)
		_area.queue_free()
		_area = null

	if reverse:
		_flank_started = true
		return

	_final_telegraphinc_finished = true
