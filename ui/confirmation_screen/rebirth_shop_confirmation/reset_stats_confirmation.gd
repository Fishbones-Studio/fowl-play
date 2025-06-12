extends ConfirmationScreen

var stats_reset_signal: Signal


func _ready() -> void:
	cancel_button.grab_focus()
	title.text = "Reset stats"
	description.text = "Are you sure you want to reset your stats? This will [color=yellow]reset your current stats to their default values[/color] and refund [color=yellow]80%[/color] of the funds you’ve spent."


func _input(_event: InputEvent) -> void:
	if (Input.is_action_just_pressed("pause") \
	or Input.is_action_just_pressed("ui_cancel") ) \
	and UIManager.previous_ui == UIManager.ui_list.get(UIEnums.UI.REBIRTH_SHOP):
		on_cancel_button_pressed()
		# Whack
		UIManager.toggle_ui(UIEnums.UI.REBIRTH_SHOP)
		UIManager.toggle_ui(UIEnums.UI.REBIRTH_SHOP)
		UIManager.get_viewport().set_input_as_handled()


func setup(params: Dictionary) -> void:
	if "stats_reset_signal" in params:
		stats_reset_signal = params["stats_reset_signal"]


func on_confirm_button_pressed() -> void:
	stats_reset_signal.emit()
	close_ui()
