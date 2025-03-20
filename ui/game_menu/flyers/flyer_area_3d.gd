extends Area3D


@export var scene_to_load: PackedScene


func _input_event(camera, event, postion, normal, shape_idx):
	# TODO: first switch to the flyers ui
	if event is InputEventMouseButton and event.pressed:
		print("Clicked on", name)
		SignalManager.switch_ui_scene.emit("uid://xhakfqnxgnrr")
		SignalManager.switch_game_scene.emit("uid://bsx7lytfj8571")
