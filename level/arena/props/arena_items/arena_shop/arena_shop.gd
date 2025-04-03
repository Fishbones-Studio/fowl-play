extends StaticBody3D

var player_in_area := false

@onready var label = $Area3D/OpenShopLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_3d_body_entered(_body: ChickenPlayer) -> void:
	player_in_area = true
	label.visible = true


func _on_area_3d_body_exited(_body: ChickenPlayer) -> void:
	label.visible = false
	player_in_area = false


func open_shop():
	SignalManager.add_ui_scene.emit("res://ui/in_arena_shop/shop/in_arena_shop.tscn") # UID fails here for some reason, so switching back to res path
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _input(event):
	if event.is_action_pressed("interact") and player_in_area:
		open_shop()
