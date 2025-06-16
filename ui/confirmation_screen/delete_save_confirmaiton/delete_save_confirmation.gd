extends ConfirmationScreen


func _ready() -> void:
	title.text = "Delete save file"
	description.text = "This will [color=yellow]reset the game to its original state[/color], permanently deleting your save file. All progress, equipments, rebirth upgrades, unlocked abilities, and other game data will be lost. This action [color=yellow]cannot be undone[/color]."
	super()


func on_confirm_button_pressed() -> void:
	GameManager.hard_reset_game()
	super()
