extends RemoteTransform3D

# Adjustable sensitivity values (tweak in the inspector)
# TODO: add a way to set these values in the game settings
# TODO: This is quite broken, fix in different branch
@export_category("Camera")
@export_range(0.1, 2.0) var horizontal_sensitivity: float = 0.5
@export_range(0.1, 2.0) var vertical_sensitivity: float = 0.5
@export_range(-180, 0) var min_degrees: float = -90.0
@export_range(0, 180) var max_degrees: float = 45.0

func _input(event):
	if event is InputEventMouseMotion:
		# Mouse sensitivity control
		rotate_y(deg_to_rad(-event.relative.x) * horizontal_sensitivity)
		rotate_x(deg_to_rad(-event.relative.y) * vertical_sensitivity)
		
		_apply_camera_clamp()

func _process(delta):
	# Calculate controller input
	var x_axis: float = Input.get_action_strength("right_stick_right") - Input.get_action_strength("right_stick_left")
	var y_axis: float = Input.get_action_strength("right_stick_up") - Input.get_action_strength("right_stick_down")

	# Apply controller input with sensitivity
	rotation.y += -x_axis * horizontal_sensitivity * delta 
	rotation.x += y_axis * vertical_sensitivity * delta   
	
	_apply_camera_clamp()

func _apply_camera_clamp():
	# Clamp the rotation to prevent flipping
	rotation.z = 0
	rotation.x = clamp(rotation.x, deg_to_rad(min_degrees), deg_to_rad(45))
