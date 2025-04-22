## Manages the basic functions for adding and displaying items in the shop, 
## to be used by different types of shops.
class_name BaseShop
extends Control

@export var max_items: int = 5
@export var item_database: BaseDatabase

var shop_items: Array[BaseResource]
var available_items: Array[BaseResource] = []
var check_inventory: bool = true
var prevent_duplicates: bool = true

@onready var shop_items_container: HBoxContainer = %ShopItemsContainer
@onready var title_label = %TitleLabel


func _ready() -> void:
	_refresh_shop()
	_setup_controller_navigation()

	# setting up controller navigation to trigger on visibility
	visibility_changed.connect(
		func():
			if visible:
				_setup_controller_navigation()
	)


func _refresh_shop() -> void:
	await get_tree().process_frame

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
		var selected_item: BaseResource = available_items[i]
		shop_items.append(selected_item)
		var shop_item: BaseShopItem = create_shop_item(selected_item)
		if not shop_item:
			push_error("Failed to create shop item for: ", selected_item.name)
			continue

		shop_items_container.add_child(shop_item)


func _get_available_items() -> Array[BaseResource]:
	var valid_items: Array[BaseResource] = []

	for item in item_database.items:
		if _should_skip_item(item):
			continue
		valid_items.append(item)

	return valid_items


func create_shop_item(_selected_item: BaseResource) -> BaseShopItem:
	printerr("Create_shop_item should be overwritten in child class")
	return


func _should_skip_item(item: BaseResource) -> bool:
	return (check_inventory and item in Inventory.get_all_items()) or (prevent_duplicates and item in shop_items)


func _setup_controller_navigation() -> void:
	# Make all shop items are focusable
	for child in shop_items_container.get_children():
		if child is Control:
			child.focus_mode = Control.FOCUS_ALL

	# Set initial focus to the first shop item, or exit button if no items
	await get_tree().process_frame
	var first_item: Node = shop_items_container.get_child(0) if shop_items_container.get_child_count() > 0 else null
	if first_item and first_item is Control:
		first_item.grab_focus()


## Abstract method
func _on_exit_button_up() -> void:
	pass
