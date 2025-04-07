extends Node

func draw_debug_trajectory(start: Vector3, end: Vector3) -> void:
	if OS.has_feature("debug"):
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
		add_child(mesh_instance)

		# Create and start timer
		var timer : Timer = Timer.new()
		timer.timeout.connect(func():
			mesh_instance.queue_free()
		)
		timer.one_shot = true
		mesh_instance.add_child(timer)
		timer.start(0.2)


func draw_debug_impact(position: Vector3, parent : Node3D, color: Color = Color.RED) -> void:
	if  OS.has_feature("debug"):
		# Create impact marker
		var impact_marker = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.4
		sphere.height = 0.2

		var material = StandardMaterial3D.new()
		material.albedo_color = color
		sphere.material = material

		impact_marker.mesh = sphere

		# First add to tree, then set position
		parent.add_child(impact_marker)
		impact_marker.global_position = position

		# Create and start timer
		var timer : Timer = Timer.new()
		timer.timeout.connect(func():
			impact_marker.queue_free()
		)
		timer.one_shot = true
		impact_marker.add_child(timer)
		timer.start(0.2)
