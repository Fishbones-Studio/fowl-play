extends ConfirmationScreen


func _ready() -> void:
	cancel_button.grab_focus()
	title.text = "Delete save file"


func on_confirm_button_pressed() -> void:
	GameManager.hard_reset_game()
	close_ui()
