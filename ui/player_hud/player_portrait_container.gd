extends CenterContainer

@export var hurt_time : float = 0.15
@export var heal_time : float = 0.25
@export var hurt_shader : ShaderMaterial
@export var heal_shader : ShaderMaterial

@onready var duration_timer : Timer = $DurationTimer
@onready var color_rect : ColorRect = $ColorRect

func _ready() -> void:
	# Set initial state
	color_rect.hide()
	
	# Connect signals
	SignalManager.player_hurt.connect(
		func() : 
			print("hurt shader")
			_on_player_health(hurt_time, hurt_shader)
	)
	SignalManager.player_heal.connect(
		func(): 
			print("heal shader")
			_on_player_health(heal_time, heal_shader)
	)

func _on_player_health(time : float, shader_material : ShaderMaterial) -> void:
	# Apply the appropriate shader
	color_rect.material = shader_material
	
	# Reset animation if already playing
	if color_rect.visible:
		duration_timer.stop()
	
	color_rect.show()
	duration_timer.start(time)

func _on_duration_timer_timeout():
	color_rect.hide()
