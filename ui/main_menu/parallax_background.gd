extends ParallaxBackground

@export_group("Parallax Settings")
## Overall parallax intensity
@export var parallax_strength: float = 0.08
## Maximum pixel offset
@export var max_offset: float = 50.0
## Smoothing speed for mouse movement
@export var smooth_speed: float = 5.0

@export_group("Layer Settings")
@export var fight_art_multiplier: float = 1.4
@export var title_multiplier: float = 0.3

@export_group("Controller Settings")
## Controller sensitivity for parallax movement
@export var controller_sensitivity: float = 200.0
## How quickly the controller input fades when not actively used
@export var controller_fade_speed: float = 2.0
## Whether to invert horizontal controller axis
@export var invert_controller_x: bool = false
## Whether to invert vertical controller axis
@export var invert_controller_y: bool = false

var target_offset: Vector2 = Vector2.ZERO
var current_offset: Vector2 = Vector2.ZERO
var controller_input_vector: Vector2 = Vector2.ZERO

@onready var fight_art_layer: ParallaxLayer = $FightArtLayer
@onready var title_layer: ParallaxLayer = $TitleLayer


func _ready() -> void:
	# Set initial motion scale for layers
	fight_art_layer.motion_scale = Vector2.ZERO
	title_layer.motion_scale = Vector2.ZERO


func _process(delta: float) -> void:
	update_parallax_offset(delta)


func update_parallax_offset(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var center: Vector2 = viewport_size * 0.5
	var final_input_offset: Vector2 = Vector2.ZERO # This will be normalized (-1 to 1)

	# Handle mouse input
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var mouse_movement_from_center: Vector2 = mouse_pos - center
	var normalized_mouse_offset: Vector2 = Vector2(
		mouse_movement_from_center.x / center.x,
		mouse_movement_from_center.y / center.y
	)

	# Handle controller input
	var raw_controller_stick: Vector2 = _get_controller_stick_input()
	
	# If controller is active, it influences the controller_input_vector
	if raw_controller_stick.length_squared() > 0.01: # Small deadzone
		controller_input_vector += raw_controller_stick * controller_sensitivity * delta
	else:
		# If no controller input, gradually fade the controller_input_vector
		controller_input_vector = controller_input_vector.lerp(Vector2.ZERO, controller_fade_speed * delta)

	# Clamp the accumulated controller input to represent a normalized range
	# This prevents runaway movement if sensitivity is high
	controller_input_vector.x = clamp(controller_input_vector.x, -1.0, 1.0)
	controller_input_vector.y = clamp(controller_input_vector.y, -1.0, 1.0)

	# Determine which input to use
	# If mouse is significantly moved from center, prioritize mouse
	if normalized_mouse_offset.length_squared() > 0.001: # Mouse is being used
		final_input_offset = normalized_mouse_offset
		# When mouse is used, quickly reduce controller's influence to avoid conflict
		controller_input_vector = controller_input_vector.lerp(Vector2.ZERO, 10.0 * delta)
	else: # Use controller input
		final_input_offset = controller_input_vector

	# Apply parallax strength and max_offset
	target_offset = final_input_offset * parallax_strength * max_offset
	# Ensure target_offset itself doesn't exceed max_offset due to strength
	target_offset.x = clamp(target_offset.x, -max_offset, max_offset)
	target_offset.y = clamp(target_offset.y, -max_offset, max_offset)

	# Smooth interpolation
	current_offset = current_offset.lerp(target_offset, smooth_speed * delta)

	# Apply to layers with different multipliers for depth
	fight_art_layer.motion_offset = current_offset * fight_art_multiplier
	title_layer.motion_offset = current_offset * title_multiplier


func _get_controller_stick_input() -> Vector2:
	# Get right stick input (following your 3D camera pattern)
	var x_axis: float = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var y_axis: float = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")

	if invert_controller_x:
		x_axis *= -1.0
	if invert_controller_y:
		y_axis *= -1.0

	return Vector2(x_axis, y_axis)
