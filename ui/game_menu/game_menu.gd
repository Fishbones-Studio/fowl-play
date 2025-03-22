extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_chicken_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Clicked on ", name)
		SignalManager.switch_ui_scene.emit("uid://dvkxcgdk0goul")


func _on_flyer_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# TODO: first switch to the flyers ui
	if event is InputEventMouseButton and event.pressed:
		print("Clicked on ", name)
		SignalManager.switch_ui_scene.emit("uid://xhakfqnxgnrr")
		SignalManager.switch_game_scene.emit("uid://bsx7lytfj8571")


func _on_shop_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Clicked on ", name)
			SignalManager.switch_ui_scene.emit("uid://c4pohtsnom3x7")
