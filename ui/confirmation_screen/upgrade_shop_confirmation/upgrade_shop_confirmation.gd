extends ConfirmationScreen

const DESCRIPTION_LABEL: String = "Are you sure you want to purchase [color=yellow]%s[/color] for [color=yellow]%d[/color][img=24x24]res://utilities/shop/art/prosperity_egg_icon.png[/img]?"

var purchased_signal: Signal
var purchase_cancelled_signal: Signal
var shop_item: BaseResource


func _ready() -> void:
	cancel_button.grab_focus()
	title.text = "Buy Upgrade"
	description.text = DESCRIPTION_LABEL % [shop_item.name, shop_item.cost]
	super()


func _input(_event: InputEvent) -> void:
	if (Input.is_action_just_pressed("pause") \
	or Input.is_action_just_pressed("ui_cancel") ) \
	and UIManager.previous_ui == UIManager.ui_list.get(UIEnums.UI.IN_ARENA_SHOP):
		on_cancel_button_pressed()
		# Whack
		UIManager.toggle_ui(UIEnums.UI.IN_ARENA_SHOP)
		UIManager.toggle_ui(UIEnums.UI.IN_ARENA_SHOP)
		UIManager.get_viewport().set_input_as_handled()


func setup(params: Dictionary) -> void:
	if "purchased_signal" in params:
		purchased_signal = params["purchased_signal"]
	if "purchase_cancelled" in params:
		purchase_cancelled_signal = params["purchase_cancelled"]
	if "shop_item" in params:
		shop_item = params["shop_item"]


func on_cancel_button_pressed() -> void:
	if purchase_cancelled_signal:
		purchase_cancelled_signal.emit()
	else:
		push_warning("'purchase_cancelled_signal' is missing and cannot be emitted.")
	UIManager.toggle_ui(UIEnums.UI.UPGRADE_SHOP_CONFIRMATION)
	super()


func on_confirm_button_pressed() -> void:
	if purchased_signal:
		purchased_signal.emit()
	else:
		push_warning("'purchased_signal' is missing and cannot be emitted.")
	UIManager.toggle_ui(UIEnums.UI.UPGRADE_SHOP_CONFIRMATION)
	super()
