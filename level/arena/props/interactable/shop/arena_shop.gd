# Arena 
extends InteractableBox


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_in_area:
		open_shop()


func open_shop() -> void:
	if UIEnums.UI.IN_ARENA_SHOP in UIManager.ui_list:
		UIManager.toggle_ui(UIEnums.UI.IN_ARENA_SHOP)
	else:
		SignalManager.add_ui_scene.emit(UIEnums.UI.IN_ARENA_SHOP)


func _on_area_3d_body_entered(_body: ChickenPlayer) -> void:
	player_in_area = true
	interact_label.visible = true


func _on_area_3d_body_exited(_body: ChickenPlayer) -> void:
	interact_label.visible = false
	player_in_area = false
