extends CenterContainer

@export_group("Shaders")
@export var hurt_time : float = 0.15
@export var heal_time : float = 0.25
@export var skew_x_value : float = 1.0
@export var hurt_shader : ShaderMaterial
@export var heal_shader : ShaderMaterial
@export var skew_shader : ShaderMaterial 

@export_group("Fov")
@export var normal_fov : float = 65.0
@export var effect_fov : float = 75.0
@export var fov_tween_duration : float = 0.1 ## How fast the FOV changes

@export_group("Border")
@export var border_starting_colour : Color
@export var border_heal_colour : Color
@export var border_hurt_colour : Color

var fov_tween : Tween ## Keeping track of the FOV tween

@onready var duration_timer : Timer = $DurationTimer
@onready var overlay_shader : ColorRect = $OverlayShader
@onready var border : ColorRect = %PlayerBorder
@onready var camera : Camera3D = %ViewportCamera


func _ready() -> void:
	# Hide by default
	overlay_shader.hide()
	
	# set border colour
	border.color = border_starting_colour
	
	if skew_shader:
		border.material = skew_shader
		skew_shader.set_shader_parameter("skew_x", skew_x_value)
	
	if camera:
		camera.fov = normal_fov
	else:
		printerr("ViewportCamera node not found!")

	# Connect signals
	SignalManager.player_hurt.connect(
		func():
			_on_player_health(hurt_time, hurt_shader, border_hurt_colour)
	)
	SignalManager.player_heal.connect(
		func():
			_on_player_health(heal_time, heal_shader, border_heal_colour)
	)


func _on_player_health(time : float, shader_material : ShaderMaterial, colour: Color) -> void:
	# check if queue_free has been called
	if is_queued_for_deletion():
		return
	
	if not camera:
		printerr("Cannot apply effect: ViewportCamera not found!")
		return

	# Setting the border colour
	border.color = colour

	# Kill previous FOV tween if it's still running
	if fov_tween and fov_tween.is_valid():
		fov_tween.kill()

	# Create a new tween owned by this node
	fov_tween = create_tween()
	# Animate the camera's fov property to the effect_fov
	fov_tween.tween_property(
		camera, "fov", effect_fov, fov_tween_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Apply the appropriate shader
	overlay_shader.material = shader_material

	# Reset shader visibility timer if already playing
	if overlay_shader.visible:
		duration_timer.stop()

	overlay_shader.show()
	
	duration_timer.start(time) # Start timer for shader visibility


func _on_duration_timer_timeout() -> void:
	# check if queue_free has been called
	if is_queued_for_deletion():
		return

	if not camera:
		return

	# resetting border colour
	border.color = border_starting_colour

	# Kill previous FOV tween if it's still running (unlikely here, but safe)
	if fov_tween and fov_tween.is_valid():
		fov_tween.kill()

	# Create a new tween to return FOV to normal
	fov_tween = create_tween()
	# Animate the camera's fov property back to the normal_fov
	fov_tween.tween_property(
		camera, "fov", normal_fov, fov_tween_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN) 

	# Hide the shader effect
	overlay_shader.hide()
