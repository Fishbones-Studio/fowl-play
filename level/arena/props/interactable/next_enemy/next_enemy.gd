# NextEnemy box, fo starting the next round
extends InteractableBox

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_in_area:
		print("starting next round")
		SignalManager.start_next_round.emit()


func _on_area_3d_body_entered(_body: ChickenPlayer) -> void:
	player_in_area = true
	interact_label.visible = true


func _on_area_3d_body_exited(_body: ChickenPlayer) -> void:
	interact_label.visible = false
	player_in_area = false
