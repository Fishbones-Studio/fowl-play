extends ConfirmationScreen

var stats_reset_signal: Signal


func _ready() -> void:
	cancel_button.grab_focus()
	title.text = "Reset stats"
	description.text = "aaaaa"


func setup(params: Dictionary) -> void:
	if "stats_reset_signal" in params:
		stats_reset_signal = params["stats_reset_signal"]


func on_confirm_button_pressed() -> void:
	stats_reset_signal.emit()
	close_ui()
