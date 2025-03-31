## manages the basic functions for adding and displaying items in the shop, to be used by different types of shops.
class_name BaseShop
extends Control

@export var max_items: int = 5
@export var item_database: BaseDatabase
@export var item_scene_packed: PackedScene

var shop_items: Array[BaseResource]

@onready var shop_items_container: HBoxContainer = %ShopItemsContainer
var check_inventory: bool = true
var prevent_duplicates: bool = true

func _ready() -> void:
	GameManager.prosperity_eggs = 9000
	refresh_shop()

func refresh_shop() -> void:
	if not shop_items_container:
		push_error("Shop container is not assigned!")
		return

	for x in range(shop_items.size(), max_items):
		var shop_item: BaseShopItem = _create_shop_item()
		if not shop_item:
			continue  # Skip if item creation failed

		var random_item: BaseResource = item_database.get_random_item()

		if _should_skip_item(random_item):
			print("Skipping item: ", random_item.name)
			shop_item.queue_free()
			continue

		print("Adding item: ", random_item.name)
		shop_items.append(random_item)
		shop_items_container.add_child(shop_item)
		shop_item.set_item_data(random_item)
		
		
func close_ui() -> void:
	queue_free()

func _create_shop_item() -> BaseShopItem:
	if not item_scene_packed:
		push_error("No item scene packed assigned!")
		return null

	var shop_item = item_scene_packed.instantiate()
	if not shop_item is BaseShopItem:
		push_error("Packed scene is not a BaseShopItem: ", item_scene_packed.resource_path)
		shop_item.queue_free()
		return null

	return shop_item

func _should_skip_item(item: BaseResource) -> bool:
	return (check_inventory and item in Inventory.items_in_inventory) or (prevent_duplicates and item in shop_items)


func _on_exit_button_button_pressed() -> void:
	close_ui()
