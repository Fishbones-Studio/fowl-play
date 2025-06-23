## Plays random music from a folder, fading between tracks.
class_name RandomMusicPlayer
extends BaseRandomAudioPlayer

const MIN_DB: float = -80.0 ## Minimum volume in decibels, used for fade out and hacky way to 'silence' the player

@export var fade_duration: float = 1.0
@export var playback_delay: float = 0.5 ## Delay before starting the next track fade
@export var start_on_ready: bool = true

@export_group("Pause Effect")
@export var pause_eq_enabled: bool = false
## EQ Band 0: ~32 Hz, 1: ~100 Hz, 2: ~320 Hz, 3: ~1 kHz, 4: ~3.2 kHz, 5: ~10 kHz
@export var pause_eq_band_0_db: float = 1.0
@export var pause_eq_band_1_db: float = 0.0
@export var pause_eq_band_2_db: float = -4.0
@export var pause_eq_band_3_db: float = -9.0
@export var pause_eq_band_4_db: float = -14.0
@export var pause_eq_band_5_db: float = -18.0
@export var pause_volume_adjustment_db: float = -6.0 ## Adjust volume by this dB when paused


var transitioning: bool = false
var stopped: bool = false
var is_game_paused: bool = false
var _eq_effect_index: int = -1
var _fading_volume_db: float = MIN_DB ## Internal volume for tweening, before pause adjustment
var _max_db : float

var tween: Tween


func _ready() -> void:
	super._ready()
	finished.connect(_on_finished)

	_fading_volume_db = MIN_DB # Initialize base volume
	# Actual self.volume_db will be set by the first _process call.
	# To ensure it's silent *before* the first _process, explicitly set it:
	_max_db = volume_db
	volume_db = MIN_DB

	is_game_paused = get_tree().paused
	if is_game_paused: # Apply initial pause effects if starting paused
		_on_pause_state_changed(true)
		# Update volume immediately based on pause state
		_update_actual_volume()


	if start_on_ready:
		call_deferred("play_random_music")


func _process(_delta: float) -> void:
	var current_tree_paused_state: bool = get_tree().paused
	if current_tree_paused_state != is_game_paused:
		is_game_paused = current_tree_paused_state
		_on_pause_state_changed(is_game_paused)

	_update_actual_volume()


func _update_actual_volume() -> void:
	var final_db: float = _fading_volume_db
	if is_game_paused and pause_volume_adjustment_db != 0.0:
		final_db += pause_volume_adjustment_db

	# Clamp to ensure volume_db stays within valid engine limits.
	# MAX_DB is the normal ceiling; adjustments typically lower it.
	self.volume_db = clamp(final_db, MIN_DB, _max_db)


func _on_pause_state_changed(paused: bool) -> void:
	# EQ Handling
	if not pause_eq_enabled:
		if _eq_effect_index != -1:
			_remove_pause_eq_effect()
	else:
		if paused:
			_add_pause_eq_effect()
		else:
			_remove_pause_eq_effect()

# Volume is handled by _update_actual_volume() in _process based on _is_game_paused
# No direct volume change here, as _process will pick it up.


func _add_pause_eq_effect() -> void:
	var bus_index: int = AudioServer.get_bus_index(bus)
	if bus_index == -1:
		push_warning(
			"RandomMusicPlayer: Could not find audio bus '%s' to add EQ." % bus
		)
		return

	if _eq_effect_index != -1:
		var effect_count: int = AudioServer.get_bus_effect_count(bus_index)
		if _eq_effect_index >= effect_count or not (
		AudioServer.get_bus_effect(bus_index, _eq_effect_index)
		is AudioEffectEQ
		):
			_eq_effect_index = -1
		else:
			return

	var eq_effect: AudioEffectEQ = AudioEffectEQ.new()
	eq_effect.set_band_gain_db(0, pause_eq_band_0_db)
	eq_effect.set_band_gain_db(1, pause_eq_band_1_db)
	eq_effect.set_band_gain_db(2, pause_eq_band_2_db)
	eq_effect.set_band_gain_db(3, pause_eq_band_3_db)
	eq_effect.set_band_gain_db(4, pause_eq_band_4_db)
	eq_effect.set_band_gain_db(5, pause_eq_band_5_db)

	AudioServer.add_bus_effect(bus_index, eq_effect)
	_eq_effect_index = AudioServer.get_bus_effect_count(bus_index) - 1


func _remove_pause_eq_effect() -> void:
	if _eq_effect_index == -1: return

	var bus_index: int = AudioServer.get_bus_index(bus)
	if bus_index == -1:
		_eq_effect_index = -1; return

	if _eq_effect_index < AudioServer.get_bus_effect_count(bus_index):
		var effect: AudioEffect = AudioServer.get_bus_effect(bus_index, _eq_effect_index)
		if effect is AudioEffectEQ:
			AudioServer.remove_bus_effect(bus_index, _eq_effect_index)
	_eq_effect_index = -1


func play_random_music() -> void:
	if stopped: return
	if _available_streams.is_empty():
		push_warning(
			"RandomMusicPlayer: No music files available to play from '%s'."
			% audio_folder
		)
		return
	if transitioning:
		return
	transitioning = true
	if playing:
		fade_out()
	else:
		_play_next_track_with_fade()


func fade_out() -> void:
	if tween and tween.is_valid(): tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE) # Smoother transitions
	tween.tween_property(self, "_fading_volume_db", MIN_DB, fade_duration)
	tween.tween_callback(_on_fade_out_finished).set_delay(playback_delay)


func fade_in() -> void:
	if tween and tween.is_valid(): tween.kill()
	# _fading_volume_db is set to MIN_DB in _play_next_track_with_fade or _on_fade_out_finished
	# before this is called for a new track.
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "_fading_volume_db", _max_db, fade_duration)
	tween.tween_callback(_on_fade_in_finished)


func _on_fade_out_finished() -> void:
	stop() # AudioStreamPlayer.stop()
	_fading_volume_db = MIN_DB # Reset base volume after fade out
	_play_next_track_with_fade()


func _play_next_track_with_fade() -> void:
	if stopped:
		transitioning = false
		return

	var next_music_stream: AudioStream = _get_next_random_stream()

	if next_music_stream:
		stream = next_music_stream
		_fading_volume_db = MIN_DB # Ensure base volume for new track starts at silence
		play()
		fade_in()
	else:
		push_warning("RandomMusicPlayer: No next music track found to play.")
		transitioning = false


func _on_fade_in_finished() -> void:
	transitioning = false
# _fading_volume_db should be at MAX_DB here.
# _update_actual_volume() in _process will handle the final self.volume_db


func _on_finished() -> void: # AudioStreamPlayer's finished signal
	if not transitioning and not stopped:
		play_random_music()


func stop_playback() -> void:
	stopped = true
	if tween and tween.is_valid(): tween.kill()
	stop()
	_fading_volume_db = MIN_DB # Set base operational volume to silent
	# _update_actual_volume() will set self.volume_db correctly in the next _process frame.
	_update_actual_volume()
	transitioning = false


func _exit_tree() -> void:
	_remove_pause_eq_effect()
	if tween and tween.is_valid(): tween.kill()
