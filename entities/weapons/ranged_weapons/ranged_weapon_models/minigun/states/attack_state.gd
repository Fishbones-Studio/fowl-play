extends BaseRangedCombatState

# TODO bullet spread is way off, also not hitting anything

@export var attack_origin: Node3D
@export var max_range: float = 1000.0
@export var spiral_spread: float = 5.0

var _fire_timer: float = 0.0
var _fire_duration : float = 0.0
var _current_angle: float = 0.0
var _angle_direction: int = 1

func enter(_previous_state, _info: Dictionary = {}) -> void:
	print("entering attack")
	_fire_timer = 0.0
	_current_angle = 0.0
	_angle_direction = 1
	_fire_duration = 0.0

func physics_process(delta: float) -> void:
	_fire_timer += delta
	_fire_duration += delta

	# Calculate fire rate based on weapon resource
	var fire_rate: float = 0.1 # TODO add to ranged weapon as interval

	while _fire_timer >= fire_rate:
		_fire_timer -= fire_rate
		_fire_bullet()

	# Check if attack duration has expired
	if _fire_duration >= weapon.current_weapon.attack_duration:
		transition_signal.emit(WeaponEnums.WeaponState.COOLDOWN, {})	

func _fire_bullet() -> void:
	print("firing a bullet")
	var fire_direction: Vector3 = _calculate_spiral_direction()
	
	# Get world space positions
	var origin: Vector3 = attack_origin.position
	var end: Vector3 = origin + fire_direction * max_range
	
	# Debug draw (lasts 3 frames)
	_draw_debug_trajectory(origin, end)
	
	var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end)
	params.collide_with_areas = true
	params.collide_with_bodies = true

	var result: Dictionary = weapon.get_world_3d().direct_space_state.intersect_ray(params)
	if result:
		process_hit(result)
		_draw_debug_impact(result.position)

	# Update spiral pattern
	_current_angle += spiral_spread
	_angle_direction *= -1

func _draw_debug_trajectory(start: Vector3, end: Vector3) -> void:
	# Create temporary debug line
	var debug_line = ImmediateMesh.new()
	var mesh_instance = MeshInstance3D.new()
	var material = StandardMaterial3D.new()
	
	material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.YELLOW_GREEN
	
	debug_line.surface_begin(Mesh.PRIMITIVE_LINES, material)
	debug_line.surface_add_vertex(start)
	debug_line.surface_add_vertex(end)
	debug_line.surface_end()
	
	mesh_instance.mesh = debug_line
	weapon.add_child(mesh_instance)
	
	# Auto-remove after short delay
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	mesh_instance.queue_free()

func _draw_debug_impact(position: Vector3) -> void:
	# Create impact marker
	var impact_marker = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	sphere.material = material
	
	impact_marker.mesh = sphere
	
	# First add to tree, then set position
	weapon.get_parent().add_child(impact_marker)
	impact_marker.global_position = position
	
	# Auto-remove after 1 second
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(impact_marker):
		impact_marker.queue_free()



func _calculate_spiral_direction() -> Vector3:
	var base_forward: Vector3  = weapon.global_transform.basis * Vector3.FORWARD
	var rotation_axis: Vector3 = weapon.global_transform.basis.y
	var angle_rad: float       = deg_to_rad(_current_angle * _angle_direction)
	return base_forward.rotated(rotation_axis, angle_rad).normalized()
