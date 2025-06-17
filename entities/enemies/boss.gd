## Enemy, but it plays audio on death
class_name Boss
extends Enemy

@export var death_audio: AudioStream


func _die() -> void:
	if state_audio_player.finished.is_connected(_on_state_audio_finished):
		state_audio_player.finished.disconnect(_on_state_audio_finished)
	play_state_audio(death_audio)

func _on_state_audio_finished(_resume_interval := true) -> void:
	super._die()
