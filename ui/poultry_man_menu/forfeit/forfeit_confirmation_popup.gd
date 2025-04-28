extends Control


func _input(_event: InputEvent) -> void:
	if (Input.is_action_just_pressed("pause") \
	or Input.is_action_just_pressed("ui_cancel") ) \
	and UIManager.previous_ui == UIManager.ui_list.get(UIEnums.UI.FORFEIT_POPUP):
		_cancel()
		# To gain focus again, toggling twice is a bit stupid though, maybe a bool
		# parameter would be more intuitive
		UIManager.toggle_ui(UIEnums.UI.FORFEIT_POPUP) # Close UI
		UIManager.toggle_ui(UIEnums.UI.FORFEIT_POPUP) # Open UI
		UIManager.get_viewport().set_input_as_handled()


func _cancel() -> void:
	UIManager.remove_ui(self)

func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.FORFEIT_POPUP)


func _on_confirm_pressed() -> void:
	GameManager.reset_game()
	UIManager.toggle_ui(UIEnums.UI.FORFEIT_POPUP)


func _on_cancel_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.FORFEIT_POPUP)
