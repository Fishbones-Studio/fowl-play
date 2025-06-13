extends ConfirmationScreen

const DESCRIPTION_TEXT: String = "Are you sure you want to purchase [color=yellow]%s (+%d)[/color] for [color=yellow]%d[/color] Feathers of Rebirth?"

var purchased_signal: Signal
var upgrade_resource: PermUpgradesResource


func _ready() -> void:
	title.text = "Buy rebirth upgrade"
	description.text = DESCRIPTION_TEXT % [upgrade_resource.name, upgrade_resource.bonus, upgrade_resource.get_level_cost(upgrade_resource.current_level + 1)]


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
	if "purchased_signal" in params:
		purchased_signal = params["purchased_signal"]
	if "upgrade_resource" in params:
		upgrade_resource = params["upgrade_resource"]


func on_confirm_button_pressed() -> void:
	purchased_signal.emit()
	close_ui()
