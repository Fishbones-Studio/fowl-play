extends Area3D


@export var scene_to_load: PackedScene

func _ready():
	set_process_input(true)
	
func _input_event(camera, event, postion, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Clicked on", name)
		get_tree().change_scene_to_file("uid://bsx7lytfj8571")
