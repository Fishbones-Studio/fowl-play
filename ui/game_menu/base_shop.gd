## manages the basic functions for adding and displaying items in the shop, to be used by different types of shops.
class_name BaseShop
extends Control

@export var max_items: int = 5

var shop_items: Array[Resource]

# These must be set in child classes in ready function
var shop_items_container: HBoxContainer
var item_database: Node
var item_scene: PackedScene
var check_inventory: bool = true
var prevent_duplicates: bool = true


func _ready() -> void:
	GameManager.prosperity_eggs = 9000
	randomize()
	refresh_shop()


func refresh_shop() -> void:
	if not shop_items_container:
		push_error("Shop container is not assigned!")
		return

	var items_in_shop = 0
	while items_in_shop < max_items:
		var shop_item = item_scene.instantiate()

		if not shop_item:
			push_error("Shop item path is not correctly assigned")
			return

		var random_item: Resource = item_database.get_random_item()

		if check_inventory and random_item in Inventory.items_in_inventory:
			continue

		if prevent_duplicates and random_item in shop_items:
			continue

		shop_items.append(random_item)
		shop_items_container.add_child(shop_item)
		shop_item.set_item(random_item)

		items_in_shop += 1
