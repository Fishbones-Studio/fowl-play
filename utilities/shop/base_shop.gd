## manages the basic functions for adding and displaying items in the shop, to be used by different types of shops.
class_name BaseShop
extends Control

@export var max_items: int = 5
@export var item_database: BaseDatabase
@export var item_scene_packed: PackedScene

var shop_items: Array[BaseResource]
var available_items: Array[BaseResource] = []

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

	# Clear previous items
	shop_items.clear()
	for child in shop_items_container.get_children():
		child.queue_free()

	# Get all possible items that can be shown
	available_items = _get_available_items()

	# Determine how many items we can actually show
	var items_to_show = min(available_items.size(), max_items)

	# Shuffle the available items to randomize selection
	available_items.shuffle()

	# Add items up to our limit
	for i in range(items_to_show):
		var shop_item = _create_shop_item()
		if not shop_item:
			continue

		var selected_item = available_items[i]
		shop_items.append(selected_item)
		shop_items_container.add_child(shop_item)
		shop_item.set_item_data(selected_item)
		print("Added item: ", selected_item.name)

func _get_available_items() -> Array[BaseResource]:
	var valid_items: Array[BaseResource] = []

	for item in item_database.items:
		if _should_skip_item(item):
			continue
		valid_items.append(item)

	return valid_items
		
		
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
