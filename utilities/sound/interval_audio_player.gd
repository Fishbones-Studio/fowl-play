## Base class for random audio playback functionality
class_name IntervalAudioPlayer
extends Node

## signal to notify the player to start playing the audio
signal play_audio(sound: AudioStream, sound_name: String)

var audio_folder: String
var file_extensions: Array[String]
var min_interval: float
var max_interval: float
var avoid_repeats: bool
var start_playing: bool

var available_audio: Array[AudioStream] = []
var current_index: int = -1

var _timer: Timer


func _init(
	_audio_folder: String,
	_file_extensions: Array[String] = ["ogg", "wav", "mp3"],
	_min_interval: float = 5.0,
	_max_interval: float = 15.0,
	_start_playing: bool = true,
	_avoid_repeats: bool = true
) -> void:
	audio_folder = _audio_folder
	file_extensions = _file_extensions
	min_interval = _min_interval
	max_interval = _max_interval
	avoid_repeats = _avoid_repeats
	start_playing = _start_playing

	_load_audio_files()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_timer()
	if available_audio.size() > 0:
		# Start playing immediately if start_playing is true
		if start_playing:
			_play_random_audio()
		else:
			# Start the timer without playing immediately
			_timer.start(randf_range(min_interval, max_interval))
	else:
		push_warning("No audio files found in: %s" % audio_folder)


func get_current_audio_name() -> String:
	if current_index >= 0 and current_index < available_audio.size():
		var audio_stream: AudioStream = available_audio[current_index]
		if audio_stream != null and audio_stream.resource_path != "":
			return audio_stream.resource_path.get_file().get_basename()
	return ""


func _load_audio_files() -> void:
	available_audio.clear()

	if not DirAccess.dir_exists_absolute(audio_folder):
		push_error(
			"Audio directory does not exist or is not accessible: %s"
			% audio_folder
		)
		return

	var file_names_in_folder: PackedStringArray = ResourceLoader.list_directory(
		audio_folder
	)

	if file_names_in_folder.is_empty():
		push_warning(
			"Audio directory '%s' is empty or contains no files recognized by ResourceLoader."
			% audio_folder
		)

	for file_name in file_names_in_folder:
		var extension: String = file_name.get_extension().to_lower()
		if extension in file_extensions:
			var resource_path: String = audio_folder.path_join(file_name)
			var audio: AudioStream = ResourceLoader.load(
				resource_path,
				"AudioStream",
				ResourceLoader.CACHE_MODE_REUSE
			)

			if audio != null:
				available_audio.append(audio)
			else:
				push_warning(
					"Could not load '%s' as AudioStream, even though it was listed and matched extension."
					% resource_path
				)

	if available_audio.is_empty() and not file_names_in_folder.is_empty():
		push_warning(
			"No loadable audio files with extensions %s found in '%s', despite files being present."
			% [str(file_extensions), audio_folder]
		)


func _setup_timer() -> void:
	_timer = Timer.new()
	add_child(_timer)
	_timer.timeout.connect(_play_random_audio)


func _play_random_audio() -> void:
	if available_audio.size() == 0:
		return

	print("Playing random audio")

	# Select next audio ensuring no immediate repeats if avoid_repeats is true
	var next_index := current_index
	if available_audio.size() > 1 and avoid_repeats:
		while next_index == current_index:
			next_index = randi() % available_audio.size()
	else: # If only one audio or repeats are allowed
		next_index = randi() % available_audio.size()

	current_index = next_index
	var audio: AudioStream = available_audio[current_index]

	# Custom playback implementation in child classes
	play_audio.emit(audio, get_current_audio_name())

	# Schedule next playback
	_schedule_next_playback(audio)


func _schedule_next_playback(audio: AudioStream) -> void:
	var interval := randf_range(min_interval, max_interval)
	if audio != null: # Ensure audio is valid before getting length
		_timer.start(interval + audio.get_length()) # Wait until current audio ends + random interval
	else:
		_timer.start(interval) # Fallback if audio is somehow null
		push_warning("Attempted to schedule playback with a null AudioStream.")
