extends ConfirmationScreen

const FOR_LABEL_TEMPLATE_TEXT: String = "Sacrificing your chicken will grant you [color=yellow]%d[/color] Feathers of Rebirth in recognition of its battles fought."

var _rounds_won_this_run: int


func _ready() -> void:
	_rounds_won_this_run = SaveManager.get_loaded_rounds_won()
	title.text = "Sacrifice Chicken"
	description.text = FOR_LABEL_TEMPLATE_TEXT % _rounds_won_this_run


func on_cancel_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.CHICKEN_SACRIFICE)


func on_confirm_button_pressed() -> void:
	if _rounds_won_this_run > 0:
		GameManager.feathers_of_rebirth += _rounds_won_this_run
	GameManager.reset_game()
	UIManager.toggle_ui(UIEnums.UI.CHICKEN_SACRIFICE)
