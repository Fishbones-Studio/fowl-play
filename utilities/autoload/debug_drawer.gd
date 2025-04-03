extends Node

func draw_debug_trajectory(start: Vector3, end: Vector3, parent : Node3D) -> void:
	if  OS.has_feature("debug"):
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
		parent.add_child(mesh_instance)

		# Auto-remove after short delay
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		mesh_instance.queue_free()

func draw_debug_impact(position: Vector3, parent : Node3D) -> void:
	if  OS.has_feature("debug"):
		# Create impact marker
		var impact_marker = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 1.0
		sphere.height = 1.0

		var material = StandardMaterial3D.new()
		material.albedo_color = Color.RED
		sphere.material = material

		impact_marker.mesh = sphere

		# First add to tree, then set position
		parent.add_child(impact_marker)
		impact_marker.global_position = position

		# Auto-remove after 1 second
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(impact_marker):
			impact_marker.queue_free()
