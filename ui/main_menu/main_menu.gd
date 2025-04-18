extends Control


func _on_quit_button_pressed():
	get_tree().quit()


func _on_play_button_pressed():
	SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
	SignalManager.switch_ui_scene.emit(UIEnums.UI.PAUSE_MENU)


func _on_settings_button_pressed() -> void:
	if UIEnums.UI.SETTINGS_MENU in UIManager.ui_list:
			UIManager.toggle_ui(UIEnums.UI.SETTINGS_MENU)
			return
	SignalManager.add_ui_scene.emit(UIEnums.UI.SETTINGS_MENU) 
