extends Area3D


@export var scene_to_load: PackedScene

func _ready():
	set_process_input(true)

func _input_event(camera, event, postion, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Clicked on", name)
			SignalManager.switch_ui_scene.emit("uid://c4pohtsnom3x7")
