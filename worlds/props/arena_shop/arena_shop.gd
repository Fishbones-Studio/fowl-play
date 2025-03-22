extends StaticBody3D

var player_in_area = false

@onready var label = $Area3D/OpenShopLabel

func _ready() -> void:
	label.visible = false

func _on_player_body_entered(body: Node3D) -> void:
	if body == GameManager.chicken_player:
		player_in_area = true
		label.visible = true

func _on_player_body_exited(body: Node3D) -> void:
	if body == GameManager.chicken_player:
		label.visible = false

func open_shop():
	SignalManager.add_ui_scene.emit("uid://dnlpj1gb126yc")
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)  
	get_tree().paused = true

func _input(event):
	if event.is_action_pressed("open_run_shop") and player_in_area:
		open_shop()
