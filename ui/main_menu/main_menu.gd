extends Control

func _on_quit_button_pressed():
	get_tree().quit()


func _on_play_button_pressed():
	SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
	queue_free()


func _on_settings_button_pressed() -> void:
	var settings_scene: PackedScene = load("uid://bwox3q508ewxc")
	if settings_scene:
		var settings_instance = settings_scene.instantiate()
		# This is kinda illegal, need to fix scene loading in another branch/pr
		get_parent().get_parent().get_parent().get_parent().add_child(settings_instance)
	else:
		push_error("Failed to load settings scene")
