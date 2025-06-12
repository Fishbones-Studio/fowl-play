################################################################################
## Handles randomized flickering effects for lights with synchronized audio 
## distortion and material emission
################################################################################
extends Node

@export_category("Connections")
@export var flicker_light: SpotLight3D
@export var flicker_timer: Timer
@export var audio_player: AudioStreamPlayer
@export var mesh: MeshInstance3D
@export var switch: bool = true
@export var periodical_switch: bool = true

@export_category("Flicker Settings")
@export var min_flicker_interval: float = 1.5
@export var max_flicker_interval: float = 6.0
@export var long_flicker_pause: float = 10.0
@export_range(1, 10) var max_flicker_count: int = 5
@export_range(0.5, 2.0) var min_pitch: float = 0.7
@export_range(0.5, 2.0) var max_pitch: float = 1.3
@export var flicker_duration_min: float = 0.2
@export var flicker_duration_max: float = 0.5
@export var emission_flicker_intensity: float = 1.0
@export var original_emission_energy: float
@export var min_turn_off_duration: float = 3.0
@export var max_turn_off_duration: float = 5.0
@export var min_turn_on_duration: float = 5.0
@export var max_turn_on_duration: float = 30.0

var _is_flickering: bool = false
var _original_energy: float
var _original_volume_db: float
var _material: BaseMaterial3D

@onready var flicker_player: AudioStreamPlayer = $FlickerPlayer
@onready var switch_timer: Timer = $SwitchTimer


func _ready() -> void:
	_original_energy = flicker_light.light_energy
	_original_volume_db = audio_player.volume_db

	if mesh:
		_material = mesh.get_active_material(0)
		if _material and not original_emission_energy:
			original_emission_energy = _material.emission_energy_multiplier

	flicker_timer.wait_time = randf_range(min_flicker_interval, max_flicker_interval)
	switch_timer.wait_time = randf_range(min_turn_off_duration, max_turn_off_duration)

	if switch:
		flicker_timer.start()
		switch_timer.start()
		audio_player.play()


func _on_flicker_timer_timeout() -> void:
	if not _is_flickering and flicker_light and switch:
		_start_flicker_effect()
		flicker_timer.wait_time = randf_range(min_flicker_interval, max_flicker_interval)
		flicker_timer.start()


func _on_switch_timer_timeout() -> void:
	if not _is_flickering and flicker_light:
		if not switch:
			switch_timer.wait_time = randf_range(min_turn_off_duration, max_turn_off_duration)
		else:
			switch_timer.wait_time = randf_range(min_turn_on_duration, max_turn_on_duration)

		_set_switch(not switch)

		switch_timer.start()


func _start_flicker_effect() -> void:
	if _is_flickering: 
		return

	flicker_player.play()
	_is_flickering = true

	var tween: Tween = create_tween()
	var flicker_count: int = randi_range(3, max_flicker_count)

	for i in flicker_count:
		var flicker_duration: float = randf_range(flicker_duration_min, flicker_duration_max)
		var half_duration: float = flicker_duration / 2
		var quarter_duration: float = flicker_duration / 4

		# Light off + audio distortion + emission off
		tween.tween_property(flicker_light, "light_energy", 0.0, half_duration)
		tween.parallel().tween_property(audio_player, "volume_db", -(_original_volume_db / 1.5), quarter_duration)
		tween.parallel().tween_property(audio_player, "pitch_scale", randf_range(min_pitch, max_pitch), quarter_duration)

		if _material:
			tween.parallel().tween_method(
				func(value: float): 
					_material.emission_energy_multiplier = value,
				original_emission_energy,
				0.01,
				quarter_duration
			)

		# Light on + audio normal + emission on
		tween.tween_property(flicker_light, "light_energy", _original_energy, half_duration)
		tween.parallel().tween_property(audio_player, "volume_db", _original_volume_db, quarter_duration)

		if _material:
			tween.parallel().tween_method(
				func(value: float): 
					_material.emission_energy_multiplier = value,
				0.01,
				original_emission_energy,
				quarter_duration
			)

		tween.tween_interval(randf_range(0.05, 0.15))

	# Reset everything after flickering completes
	tween.tween_callback(func(): 
		flicker_light.light_energy = _original_energy
		audio_player.volume_db = _original_volume_db
		audio_player.pitch_scale = 1.0
		if _material:
			_material.emission_energy_multiplier = original_emission_energy
		_is_flickering = false

		# Pause after flicker sequence
		flicker_timer.start(randf_range(long_flicker_pause - 2, long_flicker_pause + 2))
	)


func _set_switch(state: bool) -> void:
	if switch == state:
		return

	switch = state

	var tween = create_tween()
	tween.tween_property(flicker_light, "light_energy", 0.0 if not switch else _original_energy, 0.5)
	if _material:
		tween.parallel().tween_property(_material, "emission_energy_multiplier", 0.1 if not switch else original_emission_energy, 0.5)

		if not switch:
			switch_timer.wait_time = randf_range(min_turn_off_duration, max_turn_off_duration)
		else:
			switch_timer.wait_time = randf_range(min_turn_on_duration, max_turn_on_duration)

	flicker_player.play()

	if not switch and not periodical_switch:
		flicker_timer.stop()
		switch_timer.stop()
		return

	if periodical_switch:
		if flicker_timer.is_stopped(): flicker_timer.start()
		if switch_timer.is_stopped(): switch_timer.start()
