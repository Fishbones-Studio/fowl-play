extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2


func _ready() -> void:
	animation_player.play("Swing")
	animation_player_2.play("Grind")
