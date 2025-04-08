extends CenterContainer

@export_group("Shaders")
@export var hurt_time : float = 0.15
@export var heal_time : float = 0.25
@export var hurt_shader : ShaderMaterial
@export var heal_shader : ShaderMaterial

@export_group("Fov")
@export var normal_fov : float = 65.0
@export var effect_fov : float = 75.0
@export var fov_tween_duration : float = 0.1 ## How fast the FOV changes

@onready var duration_timer : Timer = $DurationTimer
@onready var color_rect : ColorRect = $ColorRect
@onready var camera : Camera3D = %ViewportCamera

var fov_tween : Tween ## Keeping track of the FOV tween


func _ready() -> void:
	# Hide by default
	color_rect.hide()
	
	if camera:
		camera.fov = normal_fov
	else:
		printerr("ViewportCamera node not found!")

	# Connect signals
	SignalManager.player_hurt.connect(
		func():
			print("hurt shader")
			_on_player_health(hurt_time, hurt_shader)
	)
	SignalManager.player_heal.connect(
		func():
			print("heal shader")
			_on_player_health(heal_time, heal_shader)
	)


func _on_player_health(time : float, shader_material : ShaderMaterial) -> void:
	if not camera:
		printerr("Cannot apply effect: ViewportCamera not found!")
		return

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
	color_rect.material = shader_material

	# Reset shader visibility timer if already playing
	if color_rect.visible:
		duration_timer.stop()

	color_rect.show()
	duration_timer.start(time) # Start timer for shader visibility


func _on_duration_timer_timeout():
	if not camera:
		return

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
	color_rect.hide()
