extends BleedHazard

@export var alive_time : float = 3.0

@onready var remove_timer : Timer = $RemoveTimer
@onready var audio_stream_player : AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready() -> void:
	var audio_length = audio_stream_player.stream.get_length()
	var max_start = max(audio_length - alive_time, 0.0)
	var start_position = randf_range(0.0, max_start)
	audio_stream_player.seek(start_position)
	audio_stream_player.play()
	remove_timer.start(alive_time)


func _on_remove_timer_timeout():
	audio_stream_player.stop()
	erase_invalid_bodies()
	queue_free()
