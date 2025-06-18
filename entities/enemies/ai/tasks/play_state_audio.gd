@tool
extends BTAction

## The audio file to play.
@export_file("*.ogg", "*.wav", "*.mp3") var file_to_play: String

## Whether this audio should loop while the action is active
## NOTE: this means this action will always be running, and has to be terminated by the BT tree in another way
@export var is_repeating: bool = false:
	set(value):
		if value:
			wait_for_completion = false
		is_repeating = value

## For one-time audio: whether to wait for completion before succeeding
@export var wait_for_completion: bool = true:
	set(value):
		if value:
			is_repeating = false
		wait_for_completion = value

## Wheter this audio should pause the enemies interval player
@export var pause_interval_player: bool = true

var audio_started: bool = false
var audio_completed: bool = false


func _generate_name() -> String:
	if file_to_play.is_empty():
		return "PlayEnemyAudio (No file)"

	var file_name: String = file_to_play.get_basename()
	var type_suffix: String = " (Repeating)" if is_repeating else " (One-time)"

	# Format the final string for the Behavior Tree editor.
	return "PlayEnemyAudio: %s%s" % [file_name, type_suffix]


func _enter() -> void:
	# Reset state
	audio_started = false
	audio_completed = false

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

	# Configure looping for repeating sounds
	if is_repeating and (audio_stream is AudioStreamOggVorbis or audio_stream is AudioStreamMP3):
		audio_stream.loop = true
	elif is_repeating and audio_stream is AudioStreamWAV:
		audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	# Connect to finished signal for one-time sounds
	if not is_repeating:
		if not agent.state_audio_player.finished.is_connected(_on_audio_finished):
			agent.state_audio_player.finished.connect(_on_audio_finished, CONNECT_ONE_SHOT)

	# Play the sound file
	agent.play_state_audio(audio_stream)
	audio_started = true


func _tick(_delta: float) -> int:
	if not agent is Enemy or not audio_started:
		return FAILURE

	# Handle repeating audio
	if is_repeating:
		# Keep playing as long as the action is active
		if not agent.state_audio_player.playing:
			# If it stopped unexpectedly, try to restart it
			agent.state_audio_player.play()
		return RUNNING  # Always running for repeating sounds

	# Handle one-time audio
	else:
		if wait_for_completion:
			# Wait for audio to complete
			return SUCCESS if audio_completed else RUNNING
		else:
			# Succeed immediately once started
			return SUCCESS


func _exit() -> void:
	# Stop repeating audio when exiting
	if agent is Enemy:
		agent.state_audio_player.stop()
	
	# Disconnect signal if connected
	if agent is Enemy and agent.state_audio_player.finished.is_connected(_on_audio_finished):
		agent.state_audio_player.finished.disconnect(_on_audio_finished)


func _on_audio_finished() -> void:
	audio_completed = true
