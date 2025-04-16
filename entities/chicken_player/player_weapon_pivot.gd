extends Node3D

func _process(delta):
	var viewport = get_viewport()
	var viewport_size = viewport.get_visible_rect().size
	var screen_center = viewport_size / 2.1
	var camera = viewport.get_camera_3d()

	if camera:
		# Shoot a ray straight forward from screen center
		# Multiply by 30 to pick a point far away
		var target_position = camera.global_position + camera.project_ray_normal(screen_center) * 30.0
		look_at(target_position)

		# Get the current vertical angle relative to the world up vector
		var current_vertical_angle = camera.global_transform.basis.get_euler().x
	else:
		printerr("Error: No 3D camera found in the viewport!")
