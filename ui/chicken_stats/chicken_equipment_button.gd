class_name ChickenEquipmentButton
extends Button

var active: bool = false:
	set(value):
		active = value
		if value:
			add_theme_stylebox_override("disabled", active_stylebox)
		else:
			add_theme_stylebox_override("disabled", inactive_stylebox)

var equipped_item: BaseResource

@onready var active_stylebox: StyleBoxFlat = preload("uid://bko4hnwdd8w0f")
@onready var inactive_stylebox: StyleBoxFlat = preload("uid://b1c8gk4cr5oa7")
