extends StaticBody3D

@onready var arena_music_player : RandomMusicPlayer = $RandomMusicPlayer

func _ready() -> void:
	SignalManager.game_won.connect(func(): arena_music_player.stop_playback())
	SignalManager.player_died.connect(func(): arena_music_player.stop_playback())
