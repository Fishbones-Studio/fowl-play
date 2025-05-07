## Plays a random audio from a folder when play_random() is called.
class_name RandomSFXPlayer extends AudioStreamPlayer3D

@export var sounds_folder: String = "res://ui/game_menu/art/random_sounds/"
@export var file_extensions: Array[String] = ["ogg", "wav", "mp3"]
@export var avoid_repeats: bool = true

var available_audio: Array[AudioStream] = []
var current_index: int = -1

func _ready() -> void:
	_load_audio_files()

func _load_audio_files() -> void:
	available_audio.clear()
	var dir := DirAccess.open(sounds_folder)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() in file_extensions:
				var audio = load(sounds_folder.path_join(file_name))
				if audio is AudioStream:
					available_audio.append(audio)
			file_name = dir.get_next()
	else:
		push_error("Could not open audio directory: %s" % sounds_folder)

func play_random() -> void:
	if available_audio.is_empty():
		push_warning("No audio files available to play.")
		return

	var next_index := current_index
	if available_audio.size() > 1 and avoid_repeats:
		while next_index == current_index:
			next_index = randi() % available_audio.size()
	else:
		next_index = randi() % available_audio.size()

	current_index = next_index
	stream = available_audio[current_index]
	play()
