extends ConfirmationScreen


func _ready() -> void:
	cancel_button.grab_focus()
	title.text = "Tip"
	description.text = "Are you sure you want to quit the game?"


func on_confirm_button_pressed() -> void:
	get_tree().quit()
