class_name ConfirmationItem 
extends BaseShopItem

var shop_item: BaseResource

@onready var type_label: Label = %TypeLabel
@onready var name_label: Label = %NameLabel
@onready var item_icon: TextureRect = %ItemIcon
@onready var description_label: Label = %DescriptionLabel
@onready var cost_label: Label = %CostLabel


func set_item_data(item: Resource) -> void:
	if not (item is BaseResource or item is InRunUpgradeResource):
		if item == null:
			push_error("Item is null")
		push_error("Item is not of appropriate type (BaseResource/InRunUpgradeResource), but instead: ", item.get_class())
		return

	shop_item = item
	print(shop_item)


func populate_visual_fields() -> void:
	name_label.text = shop_item.name
	if shop_item.icon: item_icon.texture = shop_item.icon
	type_label.text = ItemEnums.item_type_to_string(shop_item.type)
	cost_label.text = "PE: %d" % shop_item.pe_cost
	description_label.text = shop_item.description
