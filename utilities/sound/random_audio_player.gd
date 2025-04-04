## Base class for random audio playback functionality
class_name RandomAudioPlayer
extends Node

## signal to notify the player to start playing the audio
signal play_audio(ound: AudioStream, sound_name: String)

var audio_folder: String
var file_extensions: Array[String]
var min_interval: float
var max_interval: float
var avoid_repeats: bool
var start_playing : bool

var available_audio: Array[AudioStream] = []
var current_index: int = -1
var _timer: Timer

func _init(_audio_folder : String, _file_extentions : Array[String] = ["ogg", "wav", "mp3"], _min_interval : float = 5.0, _max_interval: float = 15.0, _start_playing : bool = true,  _avoid_repeats : bool = true) -> void:
	audio_folder = _audio_folder
	file_extensions = _file_extentions
	min_interval = _min_interval
	max_interval = _max_interval
	avoid_repeats = _avoid_repeats
	start_playing = _start_playing

	_load_audio_files()

func _ready() -> void:
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
		return available_audio[current_index].resource_path.get_file().get_basename()
	return ""

func _load_audio_files() -> void:
	var dir := DirAccess.open(audio_folder)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() in file_extensions:
				var audio = load(audio_folder.path_join(file_name))
				if audio is AudioStream:
					available_audio.append(audio)
			file_name = dir.get_next()
	else:
		push_error("Could not open audio directory: %s" % audio_folder)


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
	
	current_index = next_index
	var audio := available_audio[current_index]
	
	# Custom playback implementation in child classes
	play_audio.emit(audio, get_current_audio_name())
	
	# Schedule next playback
	_schedule_next_playback(audio)
	

func _schedule_next_playback(audio : AudioStream) -> void:
	var interval := randf_range(min_interval, max_interval)
	_timer.start(interval + audio.get_length()) # Wait until current audio ends + random interval
