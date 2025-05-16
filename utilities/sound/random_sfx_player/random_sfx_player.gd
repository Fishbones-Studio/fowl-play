## Plays a random audio from a folder when play_random() is called.
class_name RandomSFXPlayer
extends BaseRandomAudioPlayer

func play_random() -> void:
	if _available_streams.is_empty():
		push_warning(
			"RandomSFXPlayer: No audio files available to play from '%s'."
			% audio_folder
		)
		return

	var next_sfx_stream := _get_next_random_stream()
	if next_sfx_stream:
		stream = next_sfx_stream
		play()
	else:
		# This might happen if _get_next_random_stream somehow fails, though unlikely
		# if _available_streams was not empty.
		push_warning(
			"RandomSFXPlayer: Could not get a valid audio stream to play."
		)
