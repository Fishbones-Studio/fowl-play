extends Control


func _ready() -> void:
	SettingsManager.load_settings( get_viewport(),get_window())


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.pressed:
			_on_play_button_pressed()


func _on_play_button_pressed() -> void:
	SaveManager.load_game_data()
	SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
	UIManager.remove_ui_by_enum(UIEnums.UI.SETTINGS_MENU)
	UIManager.remove_ui(self)


func _on_settings_button_pressed() -> void:
	if UIEnums.UI.SETTINGS_MENU in UIManager.ui_list:
		UIManager.toggle_ui(UIEnums.UI.SETTINGS_MENU)
	else:
		SignalManager.add_ui_scene.emit(UIEnums.UI.SETTINGS_MENU) 


func _on_quit_button_pressed() -> void:
	get_tree().quit()
