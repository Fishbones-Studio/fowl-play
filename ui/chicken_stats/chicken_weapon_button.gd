class_name ChickenWeaponButton
extends Button

var active: bool = false:
	set(value):
		if value:
			get_theme_stylebox("disabled").bg_color = "#efecee"
		else:
			get_theme_stylebox("disabled").bg_color = "#cccbc7"

var equiped_weapon: BaseResource
