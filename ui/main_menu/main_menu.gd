extends Control

func _on_quit_button_pressed():
	get_tree().quit()


func _on_play_button_pressed():
	SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
	queue_free()


func _on_settings_button_pressed() -> void:
	SignalManager.add_ui_scene.emit("uid://bwox3q508ewxc")
