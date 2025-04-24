class_name BaseShopItem
extends PanelContainer



# Common properties
static var purchase_in_progress: bool = false :
	set(value):
		purchase_in_progress = value
		if !value:
			SignalManager.purchase_completed.emit()


var shop_item: BaseResource

var prosperity_egg_icon: CompressedTexture2D = preload("uid://be0yl1q0uryjp")
var feathers_of_rebirth_icon: CompressedTexture2D = preload("uid://brgdaqksfgmqu")

var normal_stylebox: StyleBoxFlat = preload("uid://ceyysiao8q2tl")
var hover_stylebox: StyleBoxFlat = preload("uid://c80bewaohqml0")


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	populate_visual_fields()


func can_afford() -> bool:
	match shop_item.currency_type:
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
			return GameManager.prosperity_eggs >= shop_item.cost
		CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
			return GameManager.feathers_of_rebirth >= shop_item.cost
		_:
			return false


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			attempt_purchase()
	elif event.is_action_pressed("ui_accept") and has_focus():
		attempt_purchase()


func _on_focus_entered() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", hover_stylebox)

	SignalManager.preview_shop_item.emit(shop_item)


func _on_focus_exited() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", normal_stylebox)
	
	SignalManager.preview_shop_item.emit(null)


func _on_mouse_entered() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", hover_stylebox)
	grab_focus()

	SignalManager.preview_shop_item.emit(shop_item)


func _on_mouse_exited() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", normal_stylebox)
	
	SignalManager.preview_shop_item.emit(null)


## Abstract method, overwrite in child class
func set_item_data(_item: Resource) -> void:
	push_error("set_item_data() must be implemented by child class")
	return


## Abstract method, overwrite in child class
func attempt_purchase() -> void:
	purchase_in_progress = false
	return


## Abstract method, overwrite in child class
func populate_visual_fields() -> void:
	push_error("populate_visual_fields() must be implemented by child class")
	return
