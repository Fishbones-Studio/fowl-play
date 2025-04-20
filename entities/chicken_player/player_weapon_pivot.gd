extends Node3D

@export var camera: Camera3D = null
@export_range(-90, 0 ) var max_down_angle: float = -45.0
@export_range(0, 90) var max_up_angle: float = 45.0 

var screen_center: Vector2 = Vector2.ZERO
var last_viewport_size: Vector2 = Vector2.ZERO


func _ready():
	# Grab the active 3D camera from the viewport
	camera = get_viewport().get_camera_3d()
	if camera:
		_update_screen_center()
	else:
		printerr("Error: No 3D camera found in the viewport!")

	# connect signal to viewport change
	get_viewport().size_changed.connect(_update_screen_center)


func _process(_delta) -> void:
	if not camera:
		return

	# Figure out where the center of the screen is pointing
	var target_position: Vector3 = camera.global_position + camera.project_ray_normal(screen_center) * 30.0

	# Rotate this node to look at that point
	look_at(target_position)

	rotation.x = clamp(rotation.x, deg_to_rad(max_down_angle), deg_to_rad(max_up_angle))
	rotation.y = 0


func _update_screen_center():
	# Get current viewport size and set the screen center 
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	screen_center = viewport_size / 2.1
	last_viewport_size = viewport_size
