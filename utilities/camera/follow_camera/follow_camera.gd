################################################################################
## A camera system that follows a target entity with configurable parameters.
## The follow camera uses a SpringArm3D to maintain a specific distance from the
## target, while handling collision avoidance. It updates the camera position 
## based on the target's movement and can apply the camera's Y rotation to the 
## followed entity.
################################################################################
class_name FollowCamera
extends Node3D

@export_category("Camera")
@export var camera_reference: Camera3D
@export_range(2.0, 6.0, 0.1) var camera_spring_length: float = 3.0
@export var camera_margin: float = 0.5
@export var camera_smoothness: float = 6.0
@export_range(75.0, 120.0, 0.1) var camera_fov: float = 75.0

@export_category("Entity")
@export var entity_to_follow: CharacterBody3D
@export var entity_follow_horizontal_offset: float = 2.0
@export var entity_follow_height: float = 1.4
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

var _offset_set: bool = false


func _ready() -> void:
	_load_camera_settings()

	if not camera_reference:
		push_error("No Camera3D set")
	if not entity_to_follow:
		push_error("No entity_to_follow set")
	if not spring_arm_3d:
		push_error("SpringArm3D node not found")
	if not follow_camera_transformer:
		push_error("FollowCameraTransformer node not found")

	# Ensure FollowCameraTransformer is a child of SpringArm3D
	if spring_arm_3d and follow_camera_transformer:
		if follow_camera_transformer.get_parent() != spring_arm_3d:
			var old_parent: Node = follow_camera_transformer.get_parent()
			if old_parent:
				old_parent.remove_child(follow_camera_transformer)
			spring_arm_3d.add_child(follow_camera_transformer)
			follow_camera_transformer.transform = Transform3D.IDENTITY

	spring_arm_3d.spring_length = camera_spring_length
	spring_arm_3d.margin = camera_margin

	camera_reference.fov = camera_fov

	if follow_camera_transformer and camera_reference:
		follow_camera_transformer.remote_path = camera_reference.get_path()

	# Ensure this node is a child of the entity to follow
	if entity_to_follow and get_parent() != entity_to_follow:
		call_deferred("reparent_to_entity", entity_to_follow)

	SignalManager.controls_settings_changed.connect(_load_camera_settings)


func reparent_to_entity(new_parent: Node) -> void:
	var offset := Vector3(
		entity_follow_horizontal_offset,
		entity_follow_height,
		entity_follow_distance
	)
	var intended_global_transform := Transform3D(
		basis,
		new_parent.global_transform.origin + offset
	)

	var old_parent: Node = get_parent()
	if old_parent:
		old_parent.remove_child(self)
	new_parent.add_child(self)

	global_transform = intended_global_transform
	_offset_set = true


func _input(event) -> void:
	if UIManager.game_input_blocked:
		return
	if event is InputEventMouseMotion:
		var x_input: float = event.relative.x * (-1 if invert_x_axis else 1)
		var y_input: float = event.relative.y * (-1 if invert_y_axis else 1)
		if entity_to_follow:
			entity_to_follow.rotate_y(deg_to_rad(-x_input) * horizontal_sensitivity)
		rotate_x(deg_to_rad(-y_input) * vertical_sensitivity)
		_apply_camera_clamp()


func _process(delta) -> void:
	# Only set the offset once after reparenting
	if not _offset_set and entity_to_follow and get_parent() == entity_to_follow:
		position = Vector3(
			entity_follow_horizontal_offset,
			entity_follow_height,
			entity_follow_distance
		)
		_offset_set = true

	if UIManager.game_input_blocked:
		return

	# Controller input
	var x_axis: float = (
		Input.get_action_strength("right_stick_right")
		- Input.get_action_strength("right_stick_left")
		if invert_x_axis
		else Input.get_action_strength("right_stick_left")
			- Input.get_action_strength("right_stick_right")
	)
	var y_axis: float = (
		Input.get_action_strength("right_stick_down")
		- Input.get_action_strength("right_stick_up")
		if invert_y_axis
		else Input.get_action_strength("right_stick_up")
			- Input.get_action_strength("right_stick_down")
	)

	# Apply controller input with sensitivity
	if entity_to_follow:
		entity_to_follow.rotation.y += (
			x_axis * horizontal_sensitivity * delta * controller_sensitivity
		)
	rotation.x += y_axis * vertical_sensitivity * delta * controller_sensitivity

	_apply_camera_clamp()

	## If shake intensity is more than 0, we are shaking the screen
	if shake_intensity > 0:
		## Decrease the shake intensity by lerping between the current intensity and 0.0
		shake_intensity = lerp(shake_intensity, 0.0, shake_fade_speed * delta)
		if camera_reference:
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
	rotation.z = 0.0
	rotation.x = clamp(rotation.x, deg_to_rad(min_degrees), deg_to_rad(max_degrees))


func _load_camera_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var cfg_path: String = "user://settings.cfg"
	var cfg_name: String = "controls"
	var camera_settings: Dictionary = {}
	var default_settings_resource: ControlsSetting = preload("uid://b7ndswiwixuqa")

	if default_settings_resource and default_settings_resource.default_settings:
		for dict_item: Dictionary in default_settings_resource.default_settings.duplicate(true):
			if not dict_item.is_empty():
				camera_settings[dict_item.keys()[0]] = dict_item.values()[0]

	# Attempt to load config file - return if failed
	if config.load(cfg_path) == OK and config.has_section(cfg_name):
		for control_setting_key in config.get_section_keys(cfg_name):
			camera_settings[control_setting_key] = config.get_value(
				cfg_name, control_setting_key
			)

	for key in camera_settings.keys():
		match key:
			"horizontal_sensitivity": horizontal_sensitivity = camera_settings["horizontal_sensitivity"]["value"]
			"vertical_sensitivity": vertical_sensitivity = camera_settings["vertical_sensitivity"]["value"]
			"controller_sensitivity": controller_sensitivity = camera_settings["controller_sensitivity"]["value"]
			"controller_sensitivity": controller_sensitivity = camera_settings["controller_sensitivity"]["value"]
			"camera_up_tilt": max_degrees = camera_settings["camera_up_tilt"]["value"]
			"camera_down_tilt": min_degrees = camera_settings["camera_down_tilt"]["value"]
			"camera_spring_length": 
				camera_spring_length = camera_settings["camera_spring_length"]["value"]
				spring_arm_3d.spring_length = camera_spring_length
			"camera_fov": 
				camera_fov = camera_settings["camera_fov"]["value"]
				camera_reference.fov = camera_fov
			"invert_x_axis": invert_x_axis = camera_settings["invert_x_axis"]["value"]
			"invert_y_axis": invert_y_axis = camera_settings["invert_y_axis"]["value"]
