extends SpringArm3D

@export_category("Camera")
@export var camera_reference: Camera3D
@export var camera_spring_length: float = 3.0
@export var camera_margin: float = 0.5
@export_group("Entity")
@export var entity_to_follow: CharacterBody3D
@export var entity_follow_height: float = 1.7
@export var entity_follow_distance: float = 3.5
@export var entity_follow_horizontal_offset: float = 1.2

@onready var follow_camera_transformer : RemoteTransform3D = %FollowCameraTransformer

func _ready():
	if (!camera_reference):
		push_error("No Camera3D set")

	follow_camera_transformer.remote_path = camera_reference.get_path()
	
	spring_length = camera_spring_length
	margin = camera_margin

func _process(_delta) -> void:
	if !entity_to_follow:
		return

	# Calculate target position
	var target_position: Vector3 = entity_to_follow.global_transform.origin
	target_position -= entity_to_follow.global_transform.basis.z * -entity_follow_distance
	target_position.y += entity_follow_height
	target_position.x += entity_follow_horizontal_offset

	# Apply smooth following
	follow_camera_transformer.global_position = target_position
	
	# apply camera y rotation to the player
	entity_to_follow.rotation.y = follow_camera_transformer.rotation.y
	
