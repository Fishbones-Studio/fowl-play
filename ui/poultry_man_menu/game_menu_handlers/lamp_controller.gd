# Handles randomized flickering effects for lights with synchronized audio distortion
extends Node

# Exported Variables
@export_category("connections")
@export var flicker_light: SpotLight3D
@export var flicker_timer: Timer
@export var audio_player: AudioStreamPlayer

@export_category("flicker timings")
@export var min_flicker_interval := 1.5
@export var max_flicker_interval := 6.0
@export var long_flicker_pause := 10.0
@export var max_flicker_count := 5
@export var min_pitch := 0.7
@export var max_pitch := 1.3
@export var flicker_duration_min := 0.2
@export var flicker_duration_max := 0.5


# Private Variables
var _is_flickering := false
var _original_energy: float
var _original_volume_db: float

@onready var flicker_player : AudioStreamPlayer = $FlickerPlayer


func _ready() -> void:
	_original_energy = flicker_light.light_energy
	_original_volume_db = audio_player.volume_db
	
	flicker_timer.timeout.connect(_on_flicker_timer_timeout)
	flicker_timer.wait_time = min_flicker_interval
	flicker_timer.start()
	audio_player.play()


func _on_flicker_timer_timeout() -> void:
	if not _is_flickering and flicker_light:
		_start_flicker_effect()
		flicker_timer.wait_time = randf_range(min_flicker_interval, max_flicker_interval)
		flicker_timer.start()


func _start_flicker_effect() -> void:
	flicker_player.play()
	if _is_flickering: 
		return
	
	_is_flickering = true
	
	# Explicit self.create_tween() is clearer
	var tween: Tween       = self.create_tween()  # Now using self.create_tween() explicitly
	var flicker_count: int = randi_range(3, max_flicker_count)

	for i in flicker_count:
		var flicker_duration: float = randf_range(flicker_duration_min, flicker_duration_max)
		tween.tween_property(flicker_light, "light_energy", 0.0, flicker_duration/2)
		tween.tween_property(audio_player, "volume_db", -(_original_volume_db/1.5), flicker_duration/4)
		tween.tween_property(audio_player, "pitch_scale", randf_range(min_pitch, max_pitch), flicker_duration/4)
		tween.tween_property(flicker_light, "light_energy", _original_energy, flicker_duration/2)
		tween.tween_property(audio_player, "volume_db", _original_volume_db, flicker_duration/4)
		tween.tween_interval(randf_range(0.05, 0.15))
	
	tween.tween_callback(func(): 
		flicker_light.light_energy = _original_energy
		audio_player.volume_db = _original_volume_db
		audio_player.pitch_scale = 1.0
		_is_flickering = false
		flicker_timer.start(randf_range(long_flicker_pause - 2, long_flicker_pause + 2))
	)
