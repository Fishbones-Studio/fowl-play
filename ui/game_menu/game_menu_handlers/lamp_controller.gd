extends Node

@export var flicker_light: SpotLight3D
@export var flicker_timer: Timer
@export var audio_player: AudioStreamPlayer

var is_flickering: bool = false
var original_energy: float

func _ready():
	original_energy = flicker_light.light_energy
	flicker_timer.timeout.connect(_on_flicker_timer_timeout)
	flicker_timer.wait_time = 2
	flicker_timer.start()

func _on_flicker_timer_timeout():
	if not is_flickering and flicker_light:
		start_flicker_effect()
		flicker_timer.wait_time = randf_range(3, 10)
		flicker_timer.start()

func start_flicker_effect():
	if is_flickering: return
	is_flickering = true
	
	var tween = create_tween()
	var flicker_count = randi_range(3, 5)

	for i in flicker_count:
		var flicker_duration = randf_range(0.05, 0.2)
		tween.tween_property(flicker_light, "light_energy", 0.0, flicker_duration/2)
		tween.tween_callback(_play_flicker_sound)
		tween.tween_property(flicker_light, "light_energy", original_energy, flicker_duration/2)
		tween.tween_interval(randf_range(0.05, 0.15))
	
	tween.tween_callback(func(): 
		flicker_light.light_energy = original_energy
		is_flickering = false
		flicker_timer.start(randf_range(18, 22))
	)

func _play_flicker_sound():
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.play()
