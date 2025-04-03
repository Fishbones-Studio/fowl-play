extends BaseRangedCombatState

@export var attack_origin: Node3D
@export var spiral_spread: float = 5.0
@export var max_spread_angle: float = 15.0  # Maximum bullet spread from center

var _fire_timer: float = 0.0
var _fire_duration: float = 0.0
var _current_angle: float = 0.0
var _angle_direction: int = 1

func enter(_previous_state, _info: Dictionary = {}) -> void:
	_fire_timer = 0.0
	_fire_duration = 0.0
	_current_angle = 0.0
	_angle_direction = 1

func physics_process(delta: float) -> void:
	_fire_timer += delta
	_fire_duration += delta

	# Calculate fire rate based on weapon resource
	var fire_rate: float = weapon.current_weapon.fire_rate_per_second

	while _fire_timer >= fire_rate:
		_fire_timer -= fire_rate
		_fire_bullet()

	if _fire_duration >= weapon.current_weapon.attack_duration:
		transition_signal.emit(WeaponEnums.WeaponState.COOLDOWN, {})

func _fire_bullet() -> void:
	var fire_direction: Vector3 = _calculate_spiral_direction()
	var max_range: float = weapon.current_weapon.max_range

	# Get world space positions
	var origin: Vector3 = attack_origin.global_position
	var end: Vector3 = origin + fire_direction * max_range

	# Create and configure raycast
	var raycast := RayCast3D.new()
	raycast.enabled = true
	raycast.target_position = fire_direction * max_range  # Local space
	raycast.exclude_parent = true
	raycast.collision_mask = 0b0110 # Binary for collision layers 2 and 3

	# Add to scene temporarily
	attack_origin.add_child(raycast)
	raycast.global_transform.origin = origin
	raycast.target_position = end
	raycast.force_raycast_update()

	# Create trajectory visualization
	var trajectory_mesh := ImmediateMesh.new()
	var trajectory_mesh_instance := MeshInstance3D.new()
	trajectory_mesh_instance.mesh = trajectory_mesh
	trajectory_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Add to scene
	attack_origin.add_child(trajectory_mesh_instance)

	# Begin drawing the trajectory cylinder
	trajectory_mesh.clear_surfaces()
	trajectory_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	# Set color (red with some transparency)
	var trail_color := Color(0.3, 0.3, 0.3, 0.1)
	trajectory_mesh.surface_set_color(trail_color)

	# Cylinder parameters
	var radius := 0.1  # Adjust for thickness
	var segments := 8   # More segments = smoother cylinder
	var start_pos := Vector3.ZERO

	# Create a circle of vertices around the start and end points
	var start_verts: Array[Vector3] = []
	var end_verts: Array[Vector3] = []

	# Find an orthogonal vector to the direction for our circle
	var ortho: Vector3
	if abs(fire_direction.dot(Vector3.UP)) < 0.9:
		ortho = fire_direction.cross(Vector3.UP).normalized()
	else:
		ortho = fire_direction.cross(Vector3.RIGHT).normalized()

	# Generate vertices in a circle around the line
	for i in range(segments):
		var angle := float(i) / segments * TAU
		var circle_vec := ortho.rotated(fire_direction, angle) * radius

		start_verts.append(start_pos + circle_vec)
		end_verts.append(end + circle_vec)

	# Create triangles connecting the circles
	for i in range(segments):
		var next_i := (i + 1) % segments

		# Triangle 1
		trajectory_mesh.surface_add_vertex(start_verts[i])
		trajectory_mesh.surface_add_vertex(end_verts[i])
		trajectory_mesh.surface_add_vertex(start_verts[next_i])

		# Triangle 2
		trajectory_mesh.surface_add_vertex(start_verts[next_i])
		trajectory_mesh.surface_add_vertex(end_verts[i])
		trajectory_mesh.surface_add_vertex(end_verts[next_i])

		# Add caps
		trajectory_mesh.surface_add_vertex(start_verts[i])
		trajectory_mesh.surface_add_vertex(start_verts[next_i])
		trajectory_mesh.surface_add_vertex(start_pos)

		trajectory_mesh.surface_add_vertex(end_verts[i])
		trajectory_mesh.surface_add_vertex(end)
		trajectory_mesh.surface_add_vertex(end_verts[next_i])

	# Finish drawing
	trajectory_mesh.surface_end()

	# Set up timer to remove visualization after a short time
	var timer := Timer.new()
	trajectory_mesh_instance.add_child(timer)
	timer.wait_time = 0.2  # Show for 0.2 seconds
	timer.one_shot = true
	timer.timeout.connect(func():
		trajectory_mesh_instance.queue_free()
		timer.queue_free()
	)
	timer.start()

	# Process hit
	process_hit(raycast)
	
	# Update spiral pattern with angle clamping
	_current_angle += spiral_spread * _angle_direction
	_current_angle = wrapf(_current_angle, -max_spread_angle, max_spread_angle)
	_angle_direction *= -1


func _calculate_spiral_direction() -> Vector3:
	var base_forward: Vector3 = attack_origin.basis.z
	var rotation_axis: Vector3 = attack_origin.basis.y
	var angle_rad: float = deg_to_rad(_current_angle)
	return base_forward.rotated(rotation_axis, angle_rad).normalized()
