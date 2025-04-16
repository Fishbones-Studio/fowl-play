extends Node3D

@export var camera: Camera3D = null

var screen_center = Vector2.ZERO
var last_viewport_size = Vector2.ZERO

func _ready():
	# Grab the active 3D camera from the viewport
	camera = get_viewport().get_camera_3d()
	if camera:
		update_screen_center()
	else:
		printerr("Error: No 3D camera found in the viewport!")

func update_screen_center():
	# Get current viewport size and set the screen center 
	var viewport_size = get_viewport().get_visible_rect().size
	screen_center = viewport_size / 2.1
	last_viewport_size = viewport_size

func _process(delta):
	# If the window size changed, update the screen center
	var viewport_size = get_viewport().get_visible_rect().size
	if viewport_size != last_viewport_size:
		update_screen_center()

	if not camera:
		return

	# Figure out where the center of the screen is pointing
	var target_position = camera.global_position + camera.project_ray_normal(screen_center) * 30.0
	# Rotate this node to look at that point
	look_at(target_position)
