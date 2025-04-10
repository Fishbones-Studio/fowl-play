class_name GameMenuShop
extends BaseShop

func _ready() -> void:
	check_inventory = true
	prevent_duplicates = true
	title_label.text = "Shop"
	# calls baseshop
	super()
