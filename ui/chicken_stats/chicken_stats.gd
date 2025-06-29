extends Control


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("ui_cancel"):
		_on_close_button_button_up()


func _on_close_button_button_up() -> void:
	UIManager.remove_ui(self)
	var pause_menu: Control = UIManager.ui_list.get(UIEnums.UI.PAUSE_MENU)
	if pause_menu: UIManager.current_ui = pause_menu
	UIManager.get_viewport().set_input_as_handled()

	SignalManager.focus_lost.emit()
