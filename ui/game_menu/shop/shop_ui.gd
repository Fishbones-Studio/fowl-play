extends Control

@onready var shop_items: HBoxContainer = %ShopItemsContainer


func _ready() -> void:
	GameManager.prosperity_eggs = 9000
	randomize()
	refresh_shop()


## Repopulate the shop's items
func refresh_shop() -> void:
	var items_in_shop = 0
	while items_in_shop < 5:
		var shop_item = load("uid://cc5vmtbby4xy0").instantiate()
		
		if not shop_item and not shop_item is ShopItem :
			push_error("Shop item path is not correctly assigned")
			return
		
		var random_item: Resource  = ItemDatabase.get_random_item()
		
		if random_item in Inventory.items_in_inventory:
			continue
		
		shop_items.add_child(shop_item)
		shop_item.set_item(random_item)
		
		items_in_shop += 1


func _on_exit_button_button_button_up() -> void:
	queue_free()
