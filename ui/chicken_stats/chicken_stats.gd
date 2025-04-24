extends Control


func _input(_event: InputEvent) -> void:
	# Remove stats menu, and make pause focusable again, if conditions are true
	if (Input.is_action_just_pressed("pause") \
	or Input.is_action_just_pressed("ui_cancel") ) \
	and UIManager.previous_ui == UIManager.ui_list.get(UIEnums.UI.PAUSE_MENU):
		_on_close_button_button_up()


func _on_close_button_button_up() -> void:
	UIManager.remove_ui(self)
	UIManager.handle_pause() # Close
	UIManager.handle_pause() # Open, so resume button focuses again
	UIManager.get_viewport().set_input_as_handled()
