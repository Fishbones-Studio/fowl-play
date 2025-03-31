class_name GameMenuShop extends BaseShop


func _ready() -> void:
	shop_items_container = %ShopItemsContainer  
	check_inventory = true  
	prevent_duplicates = true 
	# calls baseshop
	#super()
