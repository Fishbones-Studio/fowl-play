extends UserInterface

@onready var play_button: Button = $MarginContainer/PlayButton
@onready var music_player: AudioStreamPlayer = $MusicPlayer


func _ready() -> void:
	SettingsManager.load_settings(get_viewport(), get_window())

	if not music_player.playing:
		music_player.play()

	if play_button:
		play_button.grab_focus()

	super()


func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) or event is InputEventKey:
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


func _on_reset_button_pressed() -> void:
	SignalManager.add_ui_scene.emit(UIEnums.UI.DELETE_SAVE_POPUP)
