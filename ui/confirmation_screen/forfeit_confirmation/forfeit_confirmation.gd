extends ConfirmationScreen


func _ready() -> void:
	title.text = "Forfeit"
	description.text = "Are you sure you want to forfeit? You will [color=yellow]lose all your current equipment[/color] and any progress made in the arena."
	super()


func on_confirm_button_pressed() -> void:
	GameManager.reset_game()
	UIManager.load_game_with_loading_screen(SceneEnums.Scenes.POULTRY_MAN_MENU , UIEnums.UI.NULL)
	UIManager.paused = false


func close_ui() -> void:
	UIManager.toggle_ui(UIEnums.UI.FORFEIT_CONFIRMATION)
	super()
