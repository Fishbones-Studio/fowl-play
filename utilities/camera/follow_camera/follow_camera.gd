################################################################################
## A camera system that follows a target entity with configurable parameters.
## 
## The follow camera uses a SpringArm3D to maintain a specific distance from the
## target, while handling collision avoidance. It updates the camera position 
## based on the target's movement and can apply the camera's Y rotation to the 
## followed entity.
################################################################################
class_name FollowCamera
extends Node3D

@export_category("Camera")
@export var camera_reference: Camera3D
@export var camera_spring_length: float = 4.8
@export var camera_margin: float = 0.5
@export var camera_smoothness: float = 6.0

@export_category("Entity")
@export var entity_to_follow: CharacterBody3D
@export var entity_follow_horizontal_offset: float = 2
@export var entity_follow_height: float = 4.3
@export var entity_follow_distance: float = 0.0

@export_category("Screen Shake")
@export var shake_intensity_limit: float = 30.0 ## The maximum (+ & -) shake effect. The higher this value, the more intense a shake will be.
@export var shake_fade_speed: float = 5.0 ## The speed with which the shaking will fade after starting.


var rng = RandomNumberGenerator.new() ## Create a random number generator
var shake_intensity: float = 0.0 ## The current intensity of the shake
var horizontal_sensitivity: float = 0.5
var vertical_sensitivity: float = 0.5
var controller_sensitivity: float = 8.0
var max_degrees: float = 45.0
var min_degrees: float = -90.0
var invert_x_axis: bool = false
var invert_y_axis: bool = false

@onready var spring_arm_3d: SpringArm3D = %SpringArm3D
@onready var follow_camera_transformer: RemoteTransform3D = %FollowCameraTransformer


func _ready() -> void:
	_load_camera_settings()

	if !camera_reference:
		push_error("No Camera3D set")

	spring_arm_3d.spring_length = camera_spring_length
	spring_arm_3d.margin = camera_margin

	follow_camera_transformer.remote_path = camera_reference.get_path()
	follow_camera_transformer.lerp_weight = camera_smoothness

	# Change the parent of the follow camera and set it's position
	call_deferred("reparent", entity_to_follow)
	position = Vector3(entity_follow_horizontal_offset, entity_follow_height, entity_follow_distance)

	SignalManager.controls_settings_changed.connect(_load_camera_settings)


func _input(event) -> void:
	if UIManager.game_input_blocked: return
	if event is InputEventMouseMotion:
	 	# Apply inversion to mouse input
		var x_input: float = event.relative.x * (-1 if invert_x_axis else 1)
		var y_input: float = event.relative.y * (-1 if invert_y_axis else 1)

		# Mouse sensitivity control
		entity_to_follow.rotate_y(deg_to_rad(-x_input) * horizontal_sensitivity)
		rotate_x(deg_to_rad(-y_input) * vertical_sensitivity)
		_apply_camera_clamp()


func _process(delta) -> void:
	if UIManager.game_input_blocked: return
	# Calculate controller input
	var x_axis: float = Input.get_action_strength("right_stick_right") - Input.get_action_strength("right_stick_left") \
		if invert_x_axis else Input.get_action_strength("right_stick_left") - Input.get_action_strength("right_stick_right")
	var y_axis: float = Input.get_action_strength("right_stick_down") - Input.get_action_strength("right_stick_up") \
		if invert_y_axis else Input.get_action_strength("right_stick_up") - Input.get_action_strength("right_stick_down")

	# Apply controller input with sensitivity
	entity_to_follow.rotation.y += x_axis * horizontal_sensitivity * delta * controller_sensitivity
	rotation.x += y_axis * vertical_sensitivity * delta * controller_sensitivity

	_apply_camera_clamp()

	## If shake intensity is more than 0, we are shaking the screen
	if shake_intensity > 0:
		## Decrease the shake intensity by lerping between the current intensity and 0.0
		shake_intensity = lerp(shake_intensity, 0.0, shake_fade_speed * delta)
		## The offset gets applied to the camera
		camera_reference.h_offset = _get_random_offset().x
		camera_reference.v_offset = _get_random_offset().y


## Set the shake intensity to the intensity limit at the start of the screen shake
func apply_shake(trauma: float) -> void:
	shake_intensity = min(trauma, shake_intensity_limit)


## This calculates a random offset between -current_shake_intensity and +current_shake_intensity
## on both the x and y axis
## Use rng to make the offset more 'random'
func _get_random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_intensity, shake_intensity),
		rng.randf_range(-shake_intensity, shake_intensity)
	)


func _apply_camera_clamp() -> void:
	# Clamp the rotation to prevent flipping
	rotation.z = 0
	rotation.x = clamp(rotation.x, deg_to_rad(min_degrees), deg_to_rad(max_degrees))


func _load_camera_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var cfg_path: String = "user://settings.cfg"
	var cfg_name: String = "controls"
	var camera_settings: Array[Dictionary] = []
	var default_settings_resource: ControlsSetting = preload("uid://b7ndswiwixuqa")

	camera_settings = default_settings_resource.default_settings

	# Attempt to load config file - return if failed
	if config.load(cfg_path) == OK and config.has_section(cfg_name):
		for control_setting in config.get_section_keys(cfg_name):
			var value = config.get_value(cfg_name, control_setting)
			match control_setting:
				"horizontal_sensitivity": horizontal_sensitivity = value["value"]
				"vertical_sensitivity": vertical_sensitivity = value["value"]
				"controller_sensitivity": controller_sensitivity = value["value"]
				"controller_sensitivity": controller_sensitivity = value["value"]
				"camera_up_tilt": max_degrees = value["value"]
				"camera_down_tilt": min_degrees = value["value"]
				"invert_x_axis": invert_x_axis = value["value"]
				"invert_y_axis": invert_y_axis = value["value"]
