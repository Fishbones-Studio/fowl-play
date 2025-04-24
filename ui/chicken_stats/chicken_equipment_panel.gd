class_name ChickenEquipmentPanel
extends Panel

var equipped_item: BaseResource

var active: bool = false:
	set(value):
		active = value
		if value:
			add_theme_stylebox_override("panel", active_stylebox_dark)
		else:
			add_theme_stylebox_override("panel", inactive_stylebox_dark)

@onready var img: TextureRect = $%TextureRect
@onready var label: Label = %Label

@onready var active_stylebox_dark: StyleBoxFlat = preload("uid://cetchnns5h8tx")
@onready var inactive_stylebox_dark: StyleBoxFlat = preload("uid://cng68uuqfw6hb")
