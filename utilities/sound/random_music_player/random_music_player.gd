## Plays random music from a folder, fading between tracks.
class_name RandomMusicPlayer extends AudioStreamPlayer3D

@export var music_folder: String = "res://music/"
@export var file_extensions: Array[String] = ["ogg", "wav", "mp3"]
@export var avoid_repeats: bool = true
@export var fade_duration: float = 1.0
## Delay before starting the next track fade
@export var playback_delay: float = 0.5 
@export var start_on_ready: bool = true

var available_music: Array[AudioStream] = []
var current_index: int = -1
var transitioning: bool = false
var stopped: bool = false

var tween: Tween

const MIN_DB := -80.0
const MAX_DB := 0.0

func _ready() -> void:
	_load_music_files()
	finished.connect(_on_finished)
	# Set initial volume to a valid value (silent)
	volume_db = MIN_DB

	if start_on_ready:
		get_tree().create_timer(0.1).timeout.connect(play_random_music)

func _load_music_files() -> void:
	available_music.clear()
	var dir := DirAccess.open(music_folder)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() in file_extensions:
				var music = load(music_folder.path_join(file_name))
				if music is AudioStream:
					available_music.append(music)
			file_name = dir.get_next()
	else:
		push_error("Could not open music directory: %s" % music_folder)

func play_random_music() -> void:
	if stopped:
		return
	if available_music.is_empty():
		push_warning("No music files available to play.")
		return
	if transitioning:
		return
	transitioning = true
	# Only fade out if a song is currently playing
	if playing:
		fade_out()
	else:
		_play_next_track()

func fade_out() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "volume_db", MIN_DB, fade_duration)
	tween.tween_callback(Callable(self, "_on_fade_out_finished")).set_delay(playback_delay)

func fade_in() -> void:
	if tween:
		tween.kill()
	# Start at silent
	volume_db = MIN_DB
	tween = create_tween()
	tween.tween_property(self, "volume_db", MAX_DB, fade_duration)
	tween.tween_callback(Callable(self, "_on_fade_in_finished"))

func _on_fade_out_finished() -> void:
	stop()
	_play_next_track()

func _play_next_track() -> void:
	if stopped:
		transitioning = false
		return
	var next_index := current_index
	if available_music.size() > 1 and avoid_repeats:
		while next_index == current_index:
			next_index = randi() % available_music.size()
	else:
		next_index = randi() % available_music.size()
	current_index = next_index
	stream = available_music[current_index]
	play()
	fade_in()

func _on_fade_in_finished() -> void:
	transitioning = false

func _on_finished() -> void:
	if not transitioning and not stopped:
		play_random_music()

func stop_playback() -> void:
	stopped = true
	if tween:
		tween.kill()
	stop()
	volume_db = MIN_DB
