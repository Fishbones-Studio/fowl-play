extends ConfirmationScreen

const FOR_LABEL_TEMPLATE_TEXT: String = "Sacrificing your chicken will grant you [color=yellow]%d[/color] Feathers of Rebirth in recognition of its battles fought."

var _rounds_won_this_run: int


func _ready() -> void:
	await get_tree().process_frame
	cancel_button.grab_focus()
	_rounds_won_this_run = SaveManager.get_loaded_rounds_won()
	title.text = "Sacrifice Chicken"
	description.text = FOR_LABEL_TEMPLATE_TEXT % _rounds_won_this_run


func on_confirm_button_pressed() -> void:
	if _rounds_won_this_run > 0:
		GameManager.feathers_of_rebirth += _rounds_won_this_run

	GameManager.reset_game()
	close_ui()
