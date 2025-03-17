extends Node3D


func _on_chicken_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		SignalManager.switch_game_scene.emit("uid://dvkxcgdk0goul")


func _on_flyer_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		SignalManager.switch_ui_scene.emit("uid://xhakfqnxgnrr")
		SignalManager.switch_game_scene.emit("uid://bsx7lytfj8571")


func _on_shop_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		SignalManager.switch_game_scene.emit("uid://c4pohtsnom3x7")
