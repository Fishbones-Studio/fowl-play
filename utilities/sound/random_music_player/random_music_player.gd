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

	# First, check if the directory path itself is valid/exists.
	if not DirAccess.dir_exists_absolute(music_folder):
		push_error(
			"Music directory does not exist or is not accessible: %s"
			% music_folder
		)
		return

	var file_names_in_folder: PackedStringArray = ResourceLoader.list_directory(
		music_folder
	)

	if file_names_in_folder.is_empty():
		# This means the directory exists but ResourceLoader found no listable items.
		push_warning(
			"Music directory '%s' is empty or contains no files recognized by ResourceLoader."
			% music_folder
		)

	for file_name in file_names_in_folder:
		
		# Filter out directories and non-matching file types.
		var extension: String = file_name.get_extension().to_lower()
		if extension in file_extensions:
			var resource_path: String = music_folder.path_join(file_name)

			# Attempt to load the resource as an AudioStream.
			var music: AudioStream = ResourceLoader.load(
				resource_path,
				"AudioStream",
				ResourceLoader.CACHE_MODE_REUSE
			)

			if music != null:
				available_music.append(music)
			else:
				# This means a file with a matching extension was listed by ResourceLoader, but it couldn't be loaded as an AudioStream.
				push_warning(
					"Could not load '%s' as AudioStream, even though it was listed and matched extension."
					% resource_path
				)

	if available_music.is_empty() and not file_names_in_folder.is_empty():
		# This specific warning is if files were listed but none were loadable AudioStreams.
		push_warning(
			"No loadable music files with extensions %s found in '%s', despite files being present."
			% [str(file_extensions), music_folder]
		)

func play_random_music() -> void:
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
	tween.tween_callback(_on_fade_out_finished).set_delay(playback_delay)

func fade_in() -> void:
	if tween:
		tween.kill()
	# Start at silent
	volume_db = MIN_DB
	tween = create_tween()
	tween.tween_property(self, "volume_db", MAX_DB, fade_duration)
	tween.tween_callback(_on_fade_in_finished)

func _on_fade_out_finished() -> void:
	stop()
	_play_next_track()

func _play_next_track() -> void:
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
	if not transitioning:
		play_random_music()
