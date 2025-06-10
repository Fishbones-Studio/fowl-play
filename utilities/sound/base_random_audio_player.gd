## Base class for AudioStreamPlayer3Ds that play random streams from a folder.
class_name BaseRandomAudioPlayer
extends AudioStreamPlayer3D

@export_dir var audio_folder: String = "res://sounds/" ## Folder containing audio files
@export var file_extensions: Array[String] = ["ogg", "wav", "mp3"] ## Supported audio formats
@export var avoid_repeats: bool = true ## Avoid playing the same audio consecutively, if possible

var _available_streams: Array[AudioStream] = []
var _current_stream_index: int = -1


func _ready() -> void:
	_load_audio_streams()


func _load_audio_streams() -> void:
	_available_streams.clear()

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
				_available_streams.append(audio)
			else:
				push_warning(
					"Could not load '%s' as AudioStream, even though it was listed and matched extension."
					% resource_path
				)

	if _available_streams.is_empty():
		if not file_names_in_folder.is_empty():
			push_warning(
				"No loadable audio files with extensions %s found in '%s', despite files being present."
				% [str(file_extensions), audio_folder]
			)
		else:
			# This covers the case where the directory was empty or no matching/loadable files were found.
			push_warning(
				"No audio streams loaded from directory: %s. Check folder contents and file extensions."
				% audio_folder
			)


## Selects and returns the next AudioStream based on the configuration.
## Returns null if no streams are available.
func _get_next_random_stream() -> AudioStream:
	if _available_streams.is_empty():
		return null

	var next_index := _current_stream_index
	if _available_streams.size() > 1 and avoid_repeats:
		while next_index == _current_stream_index:
			next_index = randi() % _available_streams.size()
	elif not _available_streams.is_empty(): # Handles single item or repeats allowed
		next_index = randi() % _available_streams.size()
	else: # Should not happen if initial check passes, but as a fallback
		return null

	_current_stream_index = next_index
	return _available_streams[_current_stream_index]
