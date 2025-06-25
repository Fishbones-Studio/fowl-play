extends Node3D

@onready var saw_animation_player: AnimationPlayer = %LampAnimationPlayer


func _ready() -> void:
	saw_animation_player.play("Swing")
