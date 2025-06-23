extends ConfirmationScreen

const FOR_LABEL_TEMPLATE_TEXT: String = "Sacrificing your chicken will grant you [img=24x24]res://utilities/shop/art/feathers_of_rebirth_icon.png[/img][color=yellow]%d[/color] in recognition of the rounds it has fought and won.\n\n[color=yellow]This action will remove all equipped items and [img=24x24]res://utilities/shop/art/prosperity_egg_icon.png[/img], but rebirth upgrades and [img=24x24]res://utilities/shop/art/feathers_of_rebirth_icon.png[/img] will be preserved.[/color]"

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
