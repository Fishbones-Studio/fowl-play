extends StaticBody3D

var player_in_area: bool = false

@onready var label = $Area3D/OpenShopLabel


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_in_area:
		open_shop()


func open_shop() -> void:
	SignalManager.add_ui_scene.emit("uid://djg6luy3rxi23")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_area_3d_body_entered(_body: ChickenPlayer) -> void:
	player_in_area = true
	label.visible = true


func _on_area_3d_body_exited(_body: ChickenPlayer) -> void:
	label.visible = false
	player_in_area = false
