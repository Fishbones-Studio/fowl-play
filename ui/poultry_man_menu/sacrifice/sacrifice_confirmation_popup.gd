extends ConfirmationScreen

const FOR_LABEL_TEMPLATE_TEXT: String = "Sacrificing your chicken will grant you [color=yellow]%d[/color] Feathers of Rebirth in recognition of its battles fought.\n\n[color=yellow]Note: This action will remove all equipped items and any Prosperity Eggs, but rebirth upgrades and Feathers of Rebirth will be preserved.[/color]"

var _rounds_won_this_run: int


func _ready() -> void:
	_rounds_won_this_run = SaveManager.get_loaded_rounds_won()
	title.text = "Sacrifice Chicken"
	description.text = FOR_LABEL_TEMPLATE_TEXT % _rounds_won_this_run
	super()


func on_confirm_button_pressed() -> void:
	if _rounds_won_this_run > 0:
		GameManager.feathers_of_rebirth += _rounds_won_this_run
	if UIEnums.UI.POULTRYMAN_SHOP in UIManager.ui_list:
		UIManager.remove_ui_by_enum(UIEnums.UI.POULTRYMAN_SHOP)
	GameManager.reset_game()
	super()
