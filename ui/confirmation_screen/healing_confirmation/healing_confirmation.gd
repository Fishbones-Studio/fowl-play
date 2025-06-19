extends ConfirmationScreen

const DESCRIPTION_LABEL: String = "Are you sure you want to heal your chicken for [color=yellow]%d%%[/color] of their [color=orange]Max Health[/color] for [img=24x24]res://utilities/shop/art/prosperity_egg_icon.png[/img][color=yellow]%d[/color]?\n\nYou currently have [img=24x24]res://utilities/shop/art/prosperity_egg_icon.png[/img][color=yellow]%d[/color]."

var heal_purchased_signal: Signal
var health: int
var cost: int


func _ready() -> void:
	title.text = "Heal Chicken"
	description.text = DESCRIPTION_LABEL % [health, cost, GameManager.prosperity_eggs]
	super()


func setup(params: Dictionary) -> void:
	if "heal_purchased_signal" in params:
		heal_purchased_signal = params["heal_purchased_signal"]
	if "health" in params:
		health = params["health"]
	if "cost" in params:
		cost = params["cost"]


func on_confirm_button_pressed() -> void:
	heal_purchased_signal.emit()
	super()


func close_ui() -> void:
	UIManager.toggle_ui(UIEnums.UI.HEALING_CONFIRMATION)
	super()
