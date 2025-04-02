extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label_3d: Label3D = $Anchor/Label3D

func set_and_play(value):
	label_3d.text = str(value)
	
	animation_player.play("red_rise_and_fade")

func remove():
	queue_free()
