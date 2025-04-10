class_name ShopItem
extends BaseShopItem

var shop_item: BaseResource

@onready var type_label: Label = %TypeLabel
@onready var name_label : Label = %NameLabel
@onready var item_icon: TextureRect = %ItemIcon
@onready var description_label: Label = %DescriptionLabel
@onready var cost_label: Label = %CostLabel


func set_item_data(item: Resource) -> void:
	if not item is BaseResource or item is InRunUpgradeResource:
		if item == null:
			push_error("Item is null")
			return
		push_error("Item is not of appropriate type (BaseResource/InRunUpgradeResource), but instead: ", item.get_class())
		return
		
	shop_item = item as BaseResource

	
func populate_visual_fields() -> void:
	name_label.text = shop_item.name
	if shop_item.icon: item_icon.texture = shop_item.icon
	type_label.text = ItemEnums.item_type_to_string(shop_item.type)
	cost_label.text = str(shop_item.cost)
	description_label.text = shop_item.description
	print(shop_item)

func attempt_purchase() -> void:
	# Prevent purchase if one is already in progress or player can't afford it
	if purchase_in_progress or not can_afford():
		return

	purchase_in_progress = true

	var existing_items: Array[BaseResource] = Inventory.get_item_by_type(shop_item.type)

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
	var matching_item: BaseResource = null
	for item in existing_items:
		if item.type == shop_item.type:
			matching_items += 1
			matching_item = item

	# If player already has items of this type, show selection UI to replace
	#NOTE: Currently never triggers, as no different types exist yet
	if matching_items >= 1:
		SignalManager.add_ui_scene.emit("uid://da6m7g6ijjyop", {
			"existing_item": matching_item,
			"new_item": shop_item,
		})

	purchase_in_progress = false

	
func can_afford() -> bool:
	return GameManager.prosperity_eggs >= shop_item.cost
