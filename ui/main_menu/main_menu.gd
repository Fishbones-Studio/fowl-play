extends UserInterface

@onready var play_button: Button = $MarginContainer/PlayButton


func _ready() -> void:
	SettingsManager.load_settings(get_viewport(), get_window())

	if play_button:
		play_button.grab_focus()

	super()


func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) or event is InputEventKey:
		_on_play_button_pressed()


func _on_play_button_pressed() -> void:
	SaveManager.load_game_data()
	# Load Poultry Man menu with loading screen
	# TODO: doesn't work as expected
	UIManager.load_game_with_loading_screen("uid://21r458rvciqo")
	UIManager.clear_ui()


func _on_settings_button_pressed() -> void:
	if UIEnums.UI.SETTINGS_MENU in UIManager.ui_list:
		UIManager.toggle_ui(UIEnums.UI.SETTINGS_MENU)
	else:
		SignalManager.add_ui_scene.emit(UIEnums.UI.SETTINGS_MENU)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
