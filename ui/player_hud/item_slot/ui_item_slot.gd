class_name UiItemSlot extends CenterContainer

@export var item : BaseResource :
	set = _on_update_item

@export_group("Color")
@export var active_indicator_colour : Color
@export var item_background_colour : Color

var active : bool = false:
	set(value) :
		active = value
		active_indicator.visible = value

@onready var active_indicator : ColorRect = $ActiveIndicator
@onready var item_image : TextureRect = $ItemImage
@onready var item_background : ColorRect = $ItemBackground


func _ready() -> void:
	if active_indicator_colour:
		active_indicator.color = active_indicator_colour
	if item_background_colour:
		item_background.color = item_background_colour
	_on_update_item(item)


func _on_update_item(_item : BaseResource) -> void:
	item = _item
	if item_image && _item:
		item_image.texture = _item.icon
