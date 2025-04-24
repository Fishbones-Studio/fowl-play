class_name ChickenEquipmentPanel
extends Panel

var active: bool = false:
	set(value):
		active = value
		if value:
			add_theme_stylebox_override("panel", active_stylebox)
		else:
			add_theme_stylebox_override("panel", inactive_stylebox)

var equipped_item: BaseResource


@onready var img: TextureRect = $VBoxContainer/TextureRect
@onready var label: Label = $VBoxContainer/Label

@onready var active_stylebox: StyleBoxFlat = preload("uid://bko4hnwdd8w0f")
@onready var inactive_stylebox: StyleBoxFlat = preload("uid://b1c8gk4cr5oa7")
