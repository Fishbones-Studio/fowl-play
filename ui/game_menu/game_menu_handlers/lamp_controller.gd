# Handles randomized flickering effects for lights with synchronized audio distortion
extends Node


# Signals
signal flicker_started
signal flicker_ended


# Constants
const MIN_FLICKER_INTERVAL := 3.0
const MAX_FLICKER_INTERVAL := 10.0
const LONG_FLICKER_PAUSE := 18.0
const MAX_FLICKER_COUNT := 5
const MIN_PITCH := 0.7
const MAX_PITCH := 1.3


# Exported Variables
@export var flicker_light: SpotLight3D
@export var flicker_timer: Timer
@export var audio_player: AudioStreamPlayer


# Private Variables
var _is_flickering := false
var _original_energy: float
var _original_volume_db: float


func _ready() -> void:
	_original_energy = flicker_light.light_energy
	_original_volume_db = audio_player.volume_db
	
	flicker_timer.timeout.connect(_on_flicker_timer_timeout)
	flicker_timer.wait_time = MIN_FLICKER_INTERVAL
	flicker_timer.start()
	audio_player.play()


func _on_flicker_timer_timeout() -> void:
	if not _is_flickering and flicker_light:
		_start_flicker_effect()
		flicker_timer.wait_time = randf_range(MIN_FLICKER_INTERVAL, MAX_FLICKER_INTERVAL)
		flicker_timer.start()


func _start_flicker_effect() -> void:
	if _is_flickering: return
	
	_is_flickering = true
	flicker_started.emit()
	
	var tween = create_tween()
	var flicker_count = randi_range(3, MAX_FLICKER_COUNT)


	for i in flicker_count:
		var flicker_duration = randf_range(0.05, 0.2)
		tween.tween_property(flicker_light, "light_energy", 0.0, flicker_duration/2)
		tween.tween_property(audio_player, "volume_db", -80.0, flicker_duration/4)
		tween.tween_property(audio_player, "pitch_scale", randf_range(MIN_PITCH, MAX_PITCH), flicker_duration/4)
		tween.tween_property(flicker_light, "light_energy", _original_energy, flicker_duration/2)
		tween.tween_property(audio_player, "volume_db", _original_volume_db, flicker_duration/4)
		tween.tween_interval(randf_range(0.05, 0.15))
	
	tween.tween_callback(func(): 
		flicker_light.light_energy = _original_energy
		audio_player.volume_db = _original_volume_db
		audio_player.pitch_scale = 1.0
		_is_flickering = false
		flicker_ended.emit()
		flicker_timer.start(randf_range(LONG_FLICKER_PAUSE - 4, LONG_FLICKER_PAUSE + 4))
	)
