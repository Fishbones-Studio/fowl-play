class_name GameItemShop
extends BaseShop


func _ready() -> void:
	InputBlocker.block()
	item_database = ItemDatabase
	item_scene = load("uid://cc5vmtbby4xy0")
	shop_items_container = %ShopItemsContainer  
	check_inventory = true  
	prevent_duplicates = true 
	# calls baseshop
	super()


func _on_exit_button_button_button_up() -> void:
	InputBlocker.unblock()
	queue_free()
