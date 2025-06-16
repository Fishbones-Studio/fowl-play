class_name EquipedItemSlot 
extends PanelContainer

@export var empty_slot_texture: Texture2D

var item: BaseResource
var hover_stylebox: StyleBoxFlat = preload("uid://c80bewaohqml0")
var normal_stylebox: StyleBoxFlat = preload("uid://ceyysiao8q2tl")

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name: Label = %ItemName


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(
		func():
			focus_entered.emit()
	)
	mouse_exited.connect(
		func():
			focus_exited.emit()
	)


func display_item(_item: BaseResource) -> void:
	if _item:
		item = _item
		item_name.text = item.name
		if item.icon:
			item_icon.texture = item.icon
			item_icon.show()
		else:
			# Handle items without icons if necessary
			item_icon.texture = empty_slot_texture # Or hide
			if empty_slot_texture == null: item_icon.hide()

	else:
		item = null
		item_name.text = "Empty"
		item_icon.texture = empty_slot_texture # Show empty slot texture
		if empty_slot_texture == null: item_icon.hide()


func _on_focus_entered() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", hover_stylebox)

	SignalManager.preview_shop_item.emit(item)


func _on_focus_exited() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", normal_stylebox)
