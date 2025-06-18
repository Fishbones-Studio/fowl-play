## Enemy, but it plays audio on death
class_name Boss
extends Enemy

@export var death_audio: AudioStream


func _die() -> void:
	play_state_audio(death_audio)
	await state_audio_player.finished
	super()
