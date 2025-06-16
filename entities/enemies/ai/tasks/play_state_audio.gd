@tool
extends BTAction

## The audio file to play.
@export_file("*.ogg", "*.wav", "*.mp3") var file_to_play: String

func _generate_name() -> String:
	if file_to_play.is_empty():
		return "PlayEnemyAudio (No file)"

	var file_name: String = file_to_play.get_basename()

	# Format the final string for the Behavior Tree editor.
	return "PlayEnemyAudio: %s" % file_name


func _enter() -> void:
	# Ensure this is only used with Enemy agents
	if not agent is Enemy:
		push_error("BTAction 'PlayEnemyAudio': This action can only be used with Enemy agents.")
		return

	if file_to_play.is_empty():
		push_error("BTAction 'PlayEnemyAudio': No audio file specified.")
		return

	# Load and play the audio stream
	var audio_stream: AudioStream = load(file_to_play)
	if not audio_stream:
		push_error("BTAction 'PlayEnemyAudio': Failed to load file: %s" % file_to_play)
		return

	# Play the sound file
	agent.play_state_audio(audio_stream)

func _tick(delta):
	if agent is Enemy:
		if agent.state_audio_player.playing:
			return SUCCESS
	return FAILURE
