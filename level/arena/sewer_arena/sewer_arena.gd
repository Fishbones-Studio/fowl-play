extends StaticBody3D

@onready var arena_music_player : RandomMusicPlayer = $RandomMusicPlayer

func _ready() -> void:
	SignalManager.game_won.connect(_stop_eq_on_game_done)
	SignalManager.player_died.connect(_stop_eq_on_game_done)

func _stop_eq_on_game_done() -> void:
	arena_music_player.stop_playback()
	arena_music_player.set_process(false)
	arena_music_player.is_game_paused = false
	arena_music_player._update_actual_volume()
