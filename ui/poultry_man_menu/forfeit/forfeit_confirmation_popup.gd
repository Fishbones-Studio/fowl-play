extends Control



func _cancel() -> void:
	UIManager.remove_ui(self)

func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.FORFEIT_POPUP)


func _on_confirm_pressed() -> void:
	GameManager.reset_game()
	UIManager.toggle_ui(UIEnums.UI.FORFEIT_POPUP)


func _on_cancel_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.FORFEIT_POPUP)
