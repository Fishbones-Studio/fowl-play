extends Node3D

@onready var player_position : Marker3D = %PlayerPosition

func _ready() -> void:
	GameManager.chicken_player.global_position = player_position.global_position
	SignalManager.add_ui_scene.emit(UIEnums.UI.CONTROL_OVERVIEW, {}, false)
