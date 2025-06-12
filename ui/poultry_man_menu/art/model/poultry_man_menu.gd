extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sphere: MeshInstance3D = $LampRope/Cylinder/Sphere



func _ready() -> void:
	animation_player.play("Swing")
