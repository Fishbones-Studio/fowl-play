extends CharacterBody3D
class_name ChickenPlayer

@export var camera: Camera3D

# Player Stats
@export_range(10, 200) var max_stamina: float = 100
@export_range(10, 200) var max_health: int = 100

@onready var camera_origin : Node3D = $CameraOrigin
@onready var player_camera_transformer : RemoteTransform3D = %PlayerCameraTransformer

# TODO: split out in character and camera

# Player stats
var stamina: float = max_stamina
var health: int = max_health

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if (!camera):
		push_error("No Camera3D set")

	player_camera_transformer.remote_path = camera.get_path()

func _process(delta):
	# Calculate analog values from directional actions
	var x_axis: float = Input.get_action_strength("right_stick_right") - Input.get_action_strength("right_stick_left")
	var y_axis: float = Input.get_action_strength("right_stick_up") - Input.get_action_strength("right_stick_down")

	# Apply rotation with smoothing
	rotate_y(-x_axis * 0.5 * delta)
	camera_origin.rotate_x(-y_axis * 0.5 * delta)

	# Maintain pitch limits
	camera_origin.rotation.x = clamp(
		camera_origin.rotation.x,
		deg_to_rad(-90),
		deg_to_rad(45)
	)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x))
		camera_origin.rotate_x(deg_to_rad(-event.relative.y))
		camera_origin.rotation.x = clamp(camera_origin.rotation.x, deg_to_rad(-90), deg_to_rad(45))
		

func _physics_process(_delta: float) -> void:
	move_and_slide()
