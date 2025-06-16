## Enemy, but it plays audio on death
class_name Boss
extends Enemy

@export var death_audio : AudioStream

func _die() -> void:
	if state_audio_player.is_connected("finished", _on_state_audio_finished):
		state_audio_player.disconnect("finished", _on_state_audio_finished)
	play_state_audio(death_audio)
	if not state_audio_player.is_connected("finished", _call_parent_die):
		state_audio_player.finished.connect(_call_parent_die)
		
func _call_parent_die() -> void:
	super._die()
