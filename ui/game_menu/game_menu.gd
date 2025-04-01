extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_chicken_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Clicked on ", name)
			SignalManager.switch_ui_scene.emit("uid://dvkxcgdk0goul")


func _on_flyer_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# TODO: first switch to the flyers ui
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Clicked on ", name)
			SignalManager.emit_throttled("switch_ui_scene", ["uid://xhakfqnxgnrr"])
			SignalManager.emit_throttled("switch_game_scene", ["uid://bhnqi4fnso1hh"])


func _on_shop_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Clicked on ", name)
			SignalManager.switch_ui_scene.emit("uid://bir1j5qouane0")
