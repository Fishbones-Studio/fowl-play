extends ConfirmationScreen


func _ready() -> void:
	title.text = "Delete save file"
	description.text = "This will [color=yellow]permanently delete[/color] your save file, including all your progress, items, equipment, unlocked abilities, and any other data associated with your game. This action cannot be undone."
	super()


func on_confirm_button_pressed() -> void:
	GameManager.hard_reset_game()
	super()
