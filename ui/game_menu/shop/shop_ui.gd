extends BaseShop


func _ready() -> void:
	shop_items_container = %ShopItemsContainer  
	check_inventory = true  
	prevent_duplicates = true 
	# calls baseshop
	super()


func _on_exit_button_button_button_up() -> void:
	queue_free()
