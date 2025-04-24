class_name ConfirmationItem
extends BaseShopItem

var compare_item: BaseResource = null

@onready var type_label: Label = %TypeLabel
@onready var name_label: Label = %NameLabel
@onready var item_icon: TextureRect = %ItemIcon
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var cost_label: Label = %CostLabel


func _ready() -> void:
	cost_label.visible = false
	super()


# Create a string of the difference between the two items
func _create_compare_item_description() -> String:
	var compare_item_modifier: Array[float] = compare_item.get_modifier()
	var base_item_modifier: Array[float] = shop_item.get_modifier()
	var modifier_labels: Array[String] = shop_item.get_modifier_string()

	if compare_item_modifier.size() != base_item_modifier.size():
		push_error("Compare item and base item modifiers are not the same size: ", compare_item_modifier, " vs ", base_item_modifier)
		return ""

	var description_lines: Array[String] = []
	for i in range(compare_item_modifier.size()):
		if compare_item_modifier[i] != base_item_modifier[i]:
			var diff: float = base_item_modifier[i] - compare_item_modifier[i]
			var label: String = modifier_labels[i]
			description_lines.append("%s: %.2f" % [label, diff])

	return "\n".join(description_lines)


func set_item_data(_display_item: Resource, _compare_item: BaseResource = null) -> void:
	if not (_display_item is BaseResource or _display_item is UpgradeResource):
		if _display_item == null:
			push_error("Item is null")
		push_error("Item is not of appropriate type (BaseResource/UpgradeResource), but instead: ", _display_item.get_class())
		return

	shop_item = _display_item
	compare_item = _compare_item
	print(shop_item)


func populate_visual_fields() -> void:
	name_label.text = shop_item.name
	if shop_item.icon: item_icon.texture = shop_item.icon
	type_label.text = ItemEnums.item_type_to_string(shop_item.type)
	cost_label.text = str(shop_item.cost)
	if compare_item:
		cost_label.visible = true
		description_label.text = _create_compare_item_description()
	else:
		description_label.text = "\n".join(shop_item.get_modifier_string())
