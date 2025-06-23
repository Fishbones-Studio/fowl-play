## Plays a random sound effect from a specified folder at random intervals.
class_name IntervalSFXPlayer3D
extends AudioStreamPlayer3D

@export_dir var sounds_folder: String = "res://ui/game_menu/art/random_sounds/" ## Folder containing sound effect files
@export var min_random_distance: float = 2.0 ## Minimum distance from the player in 3D space
@export var max_random_distance: float = 10.0 ## Maximum distance from the player in 3D space
@export var file_extensions: Array[String] = ["ogg", "wav", "mp3"] ## Supported audio formats
@export var min_interval: float = 5.0 ## Minimum time between sound effects in seconds
@export var max_interval: float = 15.0 ## Maximum time between sound effects in seconds
@export var avoid_repeats: bool = true ## Avoid playing the same sound consecutively

var random_player: IntervalAudioPlayer


func _ready() -> void:
	random_player = IntervalAudioPlayer.new(sounds_folder, file_extensions, min_interval, max_interval, true, avoid_repeats)
	random_player.play_audio.connect(_on_play_sound)
	add_child(random_player)


func _on_play_sound(sound: AudioStream, _sound_name: String) -> void:
	stream = sound
	# Set random position in 3D space
	var random_angle: float = randf_range(0, 2 * PI)
	var random_distance: float = randf_range(min_random_distance, max_random_distance)
	position = Vector3(
		cos(random_angle) * random_distance,
		cos(random_angle) * random_distance,
		sin(random_angle) * random_distance
	)
	play()
