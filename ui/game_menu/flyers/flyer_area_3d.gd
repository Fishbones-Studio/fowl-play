extends Area3D

func _ready():
	set_process_input(true)


func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		print("Clicked on", name)
		SignalManager.switch_game_scene.emit("uid://bsx7lytfj8571")
		SignalManager.switch_ui_scene.emit("uid://xhakfqnxgnrr")
