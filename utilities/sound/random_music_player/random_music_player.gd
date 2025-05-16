## Plays random music from a folder, fading between tracks.
class_name RandomMusicPlayer
extends BaseRandomAudioPlayer

const MIN_DB := -80.0 ## Minimum volume in decibels, used for fade out and hacky way to 'silence' the player
const MAX_DB := 0.0

@export var fade_duration: float = 1.0
@export var playback_delay: float = 0.5 ## Delay before starting the next track fade
@export var start_on_ready: bool = true

var transitioning: bool = false
var tween: Tween


func _ready() -> void:
	super._ready()
	finished.connect(_on_finished)
	volume_db = MIN_DB # Set initial volume

	if start_on_ready:
		# Using call_deferred to ensure _available_streams is populated
		call_deferred("play_random_music")


func play_random_music() -> void:
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
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "volume_db", MIN_DB, fade_duration)
	tween.tween_callback(_on_fade_out_finished).set_delay(playback_delay)

func fade_in() -> void:
	if tween:
		tween.kill()
	volume_db = MIN_DB # Start at silent
	tween = create_tween()
	tween.tween_property(self, "volume_db", MAX_DB, fade_duration)
	tween.tween_callback(_on_fade_in_finished)

func _on_fade_out_finished() -> void:
	stop()
	_play_next_track_with_fade()

func _play_next_track_with_fade() -> void:
	var next_music_stream := _get_next_random_stream()

	if next_music_stream:
		stream = next_music_stream
		play()
		fade_in()
	else:
		push_warning(
			"RandomMusicPlayer: No next music track found to play."
		)
		transitioning = false # Reset state if no track is found

func _on_fade_in_finished() -> void:
	transitioning = false

func _on_finished() -> void:
	if not transitioning: # Only auto-play next if not already in a transition (e.g. manual stop)
		play_random_music()
