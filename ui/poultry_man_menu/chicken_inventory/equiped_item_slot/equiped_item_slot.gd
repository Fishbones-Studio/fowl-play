class_name EquipedItemSlot extends PanelContainer

@export var empty_slot_texture: Texture2D

var item : BaseResource
var hover_stylebox: StyleBoxFlat = preload("uid://c80bewaohqml0")

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name: Label = %ItemName



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
		item == null
		item_name.text = "Empty"
		item_icon.texture = empty_slot_texture # Show empty slot texture
		if empty_slot_texture == null: item_icon.hide()

func _on_focus_entered() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", hover_stylebox)

	SignalManager.preview_shop_item.emit(item)
