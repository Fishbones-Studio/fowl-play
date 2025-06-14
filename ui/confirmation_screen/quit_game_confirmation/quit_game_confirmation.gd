extends ConfirmationScreen


func _ready() -> void:
	title.text = "Quit Game"
	description.text = "Are you sure you want to quit the game?"
	super()


func on_confirm_button_pressed() -> void:
	get_tree().quit()
