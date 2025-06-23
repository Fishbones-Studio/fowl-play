extends ConfirmationScreen


func _ready() -> void:
	title.text = "Forfeit"
	description.text = "Are you sure you want to forfeit? [color=yellow]This will remove all your current equipment and reset your rounds fought and won back to zero.[/color]"
	super()


func on_confirm_button_pressed() -> void:
	GameManager.reset_game()
	UIManager.load_game_with_loading_screen(SceneEnums.Scenes.POULTRY_MAN_MENU , UIEnums.UI.NULL)
	UIManager.paused = false


func close_ui() -> void:
	UIManager.toggle_ui(UIEnums.UI.FORFEIT_CONFIRMATION)
	super()
