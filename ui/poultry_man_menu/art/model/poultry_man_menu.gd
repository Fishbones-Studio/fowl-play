extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("Swing")
	animation_player.play("Grind")
