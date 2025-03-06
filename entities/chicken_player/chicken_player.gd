extends CharacterBody3D
class_name ChickenPlayer

@export var camera: Camera3D

# Player Stats
@export_range(10, 200) var max_stamina: float = 100
@export_range(10, 200) var max_health: int = 100

@onready var camera_origin : Node3D = $CameraOrigin
@onready var player_camera_transformer : RemoteTransform3D = %PlayerCameraTransformer

# Player stats
var stamina: float = max_stamina
var health: int = max_health

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if (!camera):
		push_error("No Camera3D set")

	player_camera_transformer.remote_path = camera.get_path()
	
func _input(event):
	# TODO add controller support
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x))
		camera_origin.rotate_x(deg_to_rad(-event.relative.y))
		camera_origin.rotation.x = clamp(camera_origin.rotation.x, deg_to_rad(-90), deg_to_rad(45))
		

func _physics_process(_delta: float) -> void:
	move_and_slide()
