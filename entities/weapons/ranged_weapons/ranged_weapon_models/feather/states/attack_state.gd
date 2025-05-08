extends BaseRangedCombatState

@export var attack_origin: Node3D

# Stores the raycast to be processed in the next physics frame
var _pending_raycast: RayCast3D = null

func enter(_previous_state, _info: Dictionary = {}) -> void:
	# Start cooldown UI for player and fire a single hitscan shot
	if weapon.entity_stats.is_player:
		SignalManager.cooldown_item_slot.emit(
			weapon.current_weapon,
			weapon.current_weapon.attack_duration,
			false
		)
	_pending_raycast = null
	_fire_single_shot()

func physics_process(_delta: float) -> void:
	# Process the raycast in the physics step, then transition to cooldown
	if is_instance_valid(_pending_raycast):
		process_raycast_hit(_pending_raycast, DamageEnums.DamageTypes.TRUE)
		_pending_raycast = null
		transition_signal.emit(WeaponEnums.WeaponState.COOLDOWN, {})

func exit() -> void:
	# Clean up reference if state is exited early
	_pending_raycast = null

func _fire_single_shot() -> void:
	# Fire a single hitscan ray in the weapon's forward direction
	var fire_direction: Vector3 = -attack_origin.global_basis.z.normalized()
	var max_range: float = weapon.current_weapon.max_range

	_pending_raycast = _create_raycast(attack_origin.global_position, fire_direction, max_range)
	_create_trajectory_visualization(attack_origin.global_position, fire_direction, max_range)

func _create_raycast(
	origin: Vector3,
	direction: Vector3,
	max_range: float
) -> RayCast3D:
	# Create and configure a RayCast3D for hitscan detection
	var raycast := RayCast3D.new()
	raycast.enabled = true
	raycast.target_position = direction * max_range
	raycast.collision_mask = 0b0110

	get_tree().root.add_child(raycast)
	raycast.global_position = origin

	# Auto-remove the raycast after a short delay
	var timer := Timer.new()
	raycast.add_child(timer)
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.timeout.connect(
		func():
			if is_instance_valid(raycast) and raycast.is_inside_tree():
				raycast.queue_free()
	)
	timer.start()

	return raycast

# TODO: replace this with an actual feather effect
func _create_trajectory_visualization(
	origin: Vector3,
	direction: Vector3,
	max_range: float
) -> void:
	# Draw a short-lived tracer mesh for visual feedback
	var trajectory_mesh := ImmediateMesh.new()
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = trajectory_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	get_tree().current_scene.add_child(mesh_instance)
	mesh_instance.global_position = origin

	trajectory_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	trajectory_mesh.surface_set_color(Color(1.0, 0.5, 0.0, 0.3))

	var radius := 0.1
	var segments := 6
	var start_verts: Array[Vector3] = []
	var end_verts: Array[Vector3] = []
	var ortho := _find_orthogonal_vector(direction)

	for i in segments:
		var angle := float(i) / segments * TAU
		var circle_vec := ortho.rotated(direction, angle) * radius
		start_verts.append(circle_vec)
		end_verts.append(direction * max_range + circle_vec)

	_generate_cylinder_geometry(trajectory_mesh, start_verts, end_verts, segments)
	trajectory_mesh.surface_end()

	# Auto-remove the tracer mesh after a short delay
	var timer := Timer.new()
	mesh_instance.add_child(timer)
	timer.wait_time = 0.15
	timer.one_shot = true
	timer.timeout.connect(
		func():
			if is_instance_valid(mesh_instance) and mesh_instance.is_inside_tree():
				mesh_instance.queue_free()
	)
	timer.start()

func _find_orthogonal_vector(direction: Vector3) -> Vector3:
	# Find a vector orthogonal to the given direction
	return (
	Vector3.RIGHT
	if abs(direction.dot(Vector3.UP)) < 0.9
	else Vector3.FORWARD
	).cross(direction).normalized()

func _generate_cylinder_geometry(
	mesh: ImmediateMesh,
	start_verts: Array[Vector3],
	end_verts: Array[Vector3],
	segments: int
) -> void:
	# Build a simple cylinder mesh for the tracer effect
	for i in segments:
		var next_i := (i + 1) % segments

		mesh.surface_add_vertex(start_verts[i])
		mesh.surface_add_vertex(end_verts[i])
		mesh.surface_add_vertex(start_verts[next_i])

		mesh.surface_add_vertex(start_verts[next_i])
		mesh.surface_add_vertex(end_verts[i])
		mesh.surface_add_vertex(end_verts[next_i])
