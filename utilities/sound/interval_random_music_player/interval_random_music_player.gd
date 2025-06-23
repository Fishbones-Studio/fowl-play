## Plays a random song from a specified folder at random intervals.
extends AudioStreamPlayer

@export_dir var music_folder: String = "res://ui/game_menu/art/random_music/" ## Folder containing music files
@export var file_extensions: Array[String] = ["ogg", "wav", "mp3"] ## Supported audio formats
@export var min_interval: float = 30.0  ## Minimum time between songs in seconds
@export var max_interval: float = 60.0 ## Maximum time between songs in seconds
@export var avoid_repeats: bool = true ## Avoid playing the same song consecutively


func _ready() -> void:
	var _random_player: IntervalAudioPlayer = IntervalAudioPlayer.new(music_folder, file_extensions, min_interval, max_interval, false, avoid_repeats)
	_random_player.play_audio.connect(_on_play_sound)
	add_child(_random_player)


func _on_play_sound(sound: AudioStream, _sound_name: String) -> void:
	stream = sound
	play()
