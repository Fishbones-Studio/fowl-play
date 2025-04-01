class_name ShopItem
extends BaseShopItem

var shop_item: BaseResource

@onready var type_label: Label = %TypeLabel


func _ready() -> void:
	# setting up the labels
	name_label = %NameLabel
	item_icon = %ItemIcon
	description_label = %DescriptionLabel
	cost_label = %CostLabel


func set_item_data(item: Resource) -> void:
	if not (item is BaseResource or item is InRunUpgradeResource):
		if item == null:
			push_error("Item is null")
		push_error("Item is not of appropriate type (BaseResource/InRunUpgradeResource), but instead: ", item.get_class())
		return

	name_label.text = item.name
	type_label.text = ItemEnums.item_type_to_string(item.type)
	cost_label.text = str(item.cost)
	description_label.text = item.description
	shop_item = item
	print(shop_item)


func attempt_purchase() -> void:
	# Prevent purchase if one is already in progress or player can't afford it
	if purchase_in_progress or not can_afford():
		return

	purchase_in_progress = true

	var existing_items: Array[Resource] = Inventory.get_item_by_type(shop_item.type)

	for item in existing_items:
		if item == shop_item:
			print("Item already owned")
			purchase_in_progress = false
			return

	# Special case for abilities, since you can have 2
	var ability_condition: bool = (
	shop_item.type == ItemEnums.ItemTypes.ABILITY
	and existing_items.size() < 2
	)

	# Add item directly if player has none of this type or it's an ability (with limit)
	if existing_items.is_empty() or ability_condition:
		Inventory.add_item(shop_item)
		GameManager.update_prosperity_eggs(-int(cost_label.text))
		print("Item bought: ", name_label.text, " │ Type: ", type_label.text)
		purchase_in_progress = false
		return

	# Count items of matching type
	var matching_items: int = 0
	for item in existing_items:
		if item.type == shop_item.type:
			matching_items += 1

	# If player already has items of this type, show selection UI to replace
	#NOTE: Currently never triggers, as no different types exist yet
	if matching_items >= 1:
		SignalManager.add_ui_scene.emit("uid://da6m7g6ijjyop", {
			"existing_items": existing_items,
			"new_item": shop_item,
		})

	purchase_in_progress = false
