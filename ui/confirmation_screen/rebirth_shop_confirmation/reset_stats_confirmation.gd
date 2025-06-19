extends ConfirmationScreen

const DESCRIPTION_LABEL: String =  "Are you sure you want to reset your stats? This will [color=yellow]reset your current stats to their default values[/color] and refund [color=yellow]%d%%[/color] of the currency you’ve spent.\n\n[color=yellow]This action will refund you %d Feathers of Rebirth.[/color]"

var stats_reset_signal: Signal
var refund_percentage: int
var refund_amount: Dictionary

func _ready() -> void:
	title.text = "Reset stats"
	description.text = DESCRIPTION_LABEL % [refund_percentage, refund_amount.get(CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH, 0)]
	super()


func _input(_event: InputEvent) -> void:
	if (Input.is_action_just_pressed("pause") \
	or Input.is_action_just_pressed("ui_cancel") ) \
	and UIManager.previous_ui == UIManager.ui_list.get(UIEnums.UI.REBIRTH_SHOP):
		on_cancel_button_pressed()
		# Whack
		UIManager.toggle_ui(UIEnums.UI.REBIRTH_SHOP)
		UIManager.toggle_ui(UIEnums.UI.REBIRTH_SHOP)
		UIManager.get_viewport().set_input_as_handled()


func setup(params: Dictionary) -> void:
	if "stats_reset_signal" in params:
		stats_reset_signal = params["stats_reset_signal"]
	if "refund_percentage" in params:
		refund_percentage = params["refund_percentage"]
	if "refund_amount" in params:
		refund_amount = params["refund_amount"]


func on_confirm_button_pressed() -> void:
	stats_reset_signal.emit()
	super()
