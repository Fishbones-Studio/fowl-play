## A camera system that follows a target entity with configurable parameters.
## 
## The follow camera uses a SpringArm3D to maintain a specific distance from the target,
## while handling collision avoidance. It updates the camera position based on the target's
## movement and can apply the camera's Y rotation to the followed entity.
extends Node3D

@export_category("Camera")
@export var camera_reference: Camera3D
@export var camera_spring_length: float = 4.8
@export var camera_margin: float = 0.5
@export var camera_smoothness: float = 6.0

@export_category("Sensitity")
@export_range(0.1, 2.0) var horizontal_sensitivity: float = 0.5

@export_range(0.1, 2.0) var vertical_sensitivity: float = 0.5

@export_range(-90, 0 ) var min_degrees: float = -90.0
@export_range(0, 90) var max_degrees: float = 45.0
@export_group("Entity")
@export var entity_to_follow: CharacterBody3D
@export var entity_follow_horizontal_offset: float = 2
@export var entity_follow_height: float = 4.3
@export var entity_follow_distance: float = 0.0

@onready var spring_arm_3d: SpringArm3D = %SpringArm3D
@onready var follow_camera_transformer: RemoteTransform3D = %FollowCameraTransformer


func _ready() -> void:
	if !camera_reference:
		push_error("No Camera3D set")

	spring_arm_3d.spring_length = camera_spring_length
	spring_arm_3d.margin = camera_margin

	follow_camera_transformer.remote_path = camera_reference.get_path()
	follow_camera_transformer.lerp_weight = camera_smoothness

	# Change the parent of the follow camera and set it's position
	call_deferred("reparent", entity_to_follow)
	position = Vector3(entity_follow_horizontal_offset, entity_follow_height, entity_follow_distance)


func _input(event) -> void:
	if event is InputEventMouseMotion:
		# Mouse sensitivity control
		entity_to_follow.rotate_y(deg_to_rad(-event.relative.x) * horizontal_sensitivity)
		rotate_x(deg_to_rad(-event.relative.y) * vertical_sensitivity)
		_apply_camera_clamp()


func _process(delta) -> void:
	# Calculate controller input
	var x_axis: float = Input.get_action_strength("right_stick_right") - Input.get_action_strength("right_stick_left")
	var y_axis: float = Input.get_action_strength("right_stick_up") - Input.get_action_strength("right_stick_down")

	# Apply controller input with sensitivity
	entity_to_follow.rotation.y += -x_axis * horizontal_sensitivity * delta
	rotation.x += y_axis * vertical_sensitivity * delta

	_apply_camera_clamp()


func _apply_camera_clamp() -> void:
	# Clamp the rotation to prevent flipping
	rotation.z = 0
	rotation.x = clamp(rotation.x, deg_to_rad(min_degrees), deg_to_rad(max_degrees))
