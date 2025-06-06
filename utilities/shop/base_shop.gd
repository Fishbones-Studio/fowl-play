## Manages the basic functions for adding and displaying items in the shop,
## to be used by different types of shops.
class_name BaseShop
extends Control

## Amount of items to show in the shop
@export_range(4, 8) var max_items: int
## Database Node extending `BaseDatabase`
@export var item_database: BaseDatabase
## Make the first item free
@export var first_item_free: bool = false

var shop_items: Array[BaseResource]
var available_items: Array[BaseResource] = []
var check_inventory: bool = true
var prevent_duplicates: bool = true
var actual_max_items: int

var current_previewed_item: BaseResource = null

@onready var shop_title_label: Label = %ShopLabel
@onready var shop_items_container: GridContainer = %ShopItemsContainer
@onready var shop_preview_container: ItemPreviewContainer = %ItemPreviewContainer
@onready var shop_preview_size_placeholder: Control = %SizePlaceholder
@onready var cheat_button_container: HBoxContainer = %CheatButtonsContainer


func _ready() -> void:
	if not OS.has_feature("debug") and cheat_button_container:
		cheat_button_container.queue_free()

	_refresh_shop()
	_setup_controller_navigation()

	# setting up controller navigation to trigger on visibility
	visibility_changed.connect(
		func():
			if visible:
				_setup_controller_navigation()
	)

	actual_max_items = max_items

	SignalManager.purchase_completed.connect(_setup_controller_navigation)


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

	var selected_items: Array[BaseResource] = _get_shop_selection(
		available_items, items_to_show
	)

	var free_item_applied: bool = false
	for selected_item in selected_items:
		shop_items.append(selected_item)

		if first_item_free and selected_item.is_free and not free_item_applied and selected_item.cost > 0:
			selected_item.cost = 0
			free_item_applied = true

		var shop_item: BaseShopItem = create_shop_item(selected_item)
		if not shop_item:
			push_error("Failed to create shop item for: ", selected_item.name)
			continue

		shop_items_container.add_child(shop_item)

		# Connect signals for preview logic
		shop_item.hovered.connect(_on_populate_visual_fields)
		shop_item.focused.connect(_on_populate_visual_fields)
		shop_item.unhovered.connect(_on_shop_item_unhovered)


func _get_available_items() -> Array[BaseResource]:
	var valid_items: Array[BaseResource] = []

	for item in item_database.items:
		if _should_skip_item(item):
			continue
		valid_items.append(item)

	return valid_items


func create_shop_item(_selected_item: BaseResource) -> BaseShopItem:
	printerr("Create_shop_item should be overwritten in child class")
	return null


func _should_skip_item(item: BaseResource) -> bool:
	if not item.purchasable or item.drop_chance <= 0:
		return true
	if check_inventory and item in Inventory.get_all_items():
		return true
	if prevent_duplicates and item in shop_items:
		return true
	return false


func _get_weighted_random_items(
	items: Array[BaseResource], count: int
) -> Array[BaseResource]:
	var selected: Array[BaseResource] = []
	var pool := items.duplicate()
	while selected.size() < count and pool.size() > 0:
		var total_weight := 0
		for item_res in pool: # item_res is BaseResource
			total_weight += item_res.drop_chance
		if total_weight == 0:
			break
		var r := randi() % total_weight
		var cumulative := 0
		var chosen_index := -1
		for i in pool.size():
			cumulative += pool[i].drop_chance
			if r < cumulative:
				chosen_index = i
				break
		if chosen_index >= 0:
			selected.append(pool[chosen_index]) # Appending BaseResource
			pool.remove_at(chosen_index)
	return selected


func _select_one_per_type(items: Array[BaseResource]) -> Array[BaseResource]:
	var items_by_type : Dictionary[ItemEnums.ItemTypes, Array]= {}
	for item in items:
		if not items_by_type.has(item.type):
			items_by_type[item.type] = []
		items_by_type[item.type].append(item)

	var selected: Array[BaseResource] = []
	for type in items_by_type.keys():
		var typed_items : Array[BaseResource] = []
		# Convert to Array[BaseResource] for type safety
		for item in items_by_type[type]:
			if not item is BaseResource:
				push_error("Item is not a BaseResource: ", item)
				continue
			else:
				typed_items.append(item)

		var chosen := _get_weighted_random_items(typed_items, 1)
		if chosen.size() > 0:
			selected.append(chosen[0])
	return selected


# Fill the remaining slots with random items from the pool
func _fill_remaining(
	selected_items: Array[BaseResource],
	all_items: Array[BaseResource],
	count: int
) -> Array[BaseResource]:
	# Making a copy of the pool to avoid modifying the original
	var pool: Array = all_items.duplicate()
	# Remove already selected items from the pool
	for item in selected_items:
		if item in pool: # Ensure item is actually in pool before erasing
			pool.erase(item)
	var remaining_items := _get_weighted_random_items(pool, count)
	return selected_items + remaining_items


func _get_shop_selection(
	items: Array[BaseResource], current_max_items: int
) -> Array[BaseResource]:
	# Select at least one item per type, so the player always has some variety
	var selected_by_type: Array[BaseResource] = _select_one_per_type(items)
	# If we have enough items, return them
	var remaining_count = max(0, current_max_items - selected_by_type.size())
	# Else, fill the rest with random items
	return _fill_remaining(selected_by_type, items, remaining_count)


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


func _on_populate_visual_fields(item: BaseResource) -> void:
	current_previewed_item = item
	shop_preview_container.visible = item != null
	shop_preview_size_placeholder.visible = item == null
	if item == null:
		return

	shop_preview_container.setup(item)


func _maybe_clear_preview(leaving_item: BaseResource) -> void:
	if current_previewed_item == leaving_item:
		current_previewed_item = null
		_on_populate_visual_fields(null)


func _on_shop_item_unhovered(item: BaseResource) -> void:
	await get_tree().process_frame
	var focused: Control = get_viewport().gui_get_focus_owner()
	if not (focused and focused.is_in_group("shop_item")):
		_maybe_clear_preview(item)


## Abstract method
func _on_close_button_pressed() -> void:
	pass


func _on_show_all_items_toggled(toggled_on: bool) -> void:
	if toggled_on:
		max_items = 99999
	else:
		max_items = actual_max_items
	_refresh_shop()


func _on_refresh_shop_button_pressed() -> void:
	_refresh_shop()
