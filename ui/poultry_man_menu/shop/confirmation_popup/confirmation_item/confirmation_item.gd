class_name ConfirmationItem
extends BaseShopItem

var compare_item: BaseResource = null

@onready var type_label: Label = %TypeLabel
@onready var name_label: Label = %NameLabel
@onready var item_icon: TextureRect = %ItemIcon
@onready var description_label: RichTextLabel = %DescriptionLabel

@onready var item_cost_label: Label = %ItemCostLabel
@onready var item_currency_icon : TextureRect = %ItemCurrencyIcon
@onready var currency_container : HBoxContainer = $ConfirmationItemContainer/CurrencyHboxContainer


func _ready() -> void:
	currency_container.visible = false
	super()


# Create a string of the difference between the two items
func _create_compare_item_description() -> String:
	var compare_item_modifier: Array[float] = compare_item.get_modifier()
	var base_item_modifier: Array[float] = shop_item.get_modifier()
	var base_modifier_labels: Array[String] = shop_item.get_modifier_string()

	if compare_item_modifier.size() != base_item_modifier.size():
		push_error("Compare item and base item modifiers are not the same size: ", compare_item_modifier, " vs ", base_item_modifier)
		return ""

	var base_label_idx: int = 0
	var description_lines: Array[String] = []

	for i in range(base_item_modifier.size()):
		var base_val: float = base_item_modifier[i]
		var compare_val: float = compare_item_modifier[i]

		var current_label_text: String
		var suffix: String = ""

		if not is_zero_approx(base_val):
			if base_label_idx < base_modifier_labels.size():
				current_label_text = base_modifier_labels[base_label_idx]

				var clean_label: String = current_label_text.strip_edges()
				var tag_end_pos: int = clean_label.rfind("[/color]")
				var check_pos: int = -1

				if tag_end_pos != -1:
					if tag_end_pos > 0:
						check_pos = tag_end_pos - 1
				elif not clean_label.is_empty():
					check_pos = clean_label.length() - 1

				if check_pos != -1:
					var potential_suffix: String = clean_label[check_pos]
					print("Potential Suffix: ", potential_suffix)
					if !(potential_suffix.is_valid_int() || potential_suffix.is_valid_float()):
						suffix = potential_suffix

				base_label_idx += 1
			else:
				push_warning("Mismatch: Ran out of base modifier labels for non-zero base values at index %d." % i)
			
		# Setting a fallback label
		if current_label_text.is_empty():
			current_label_text = "[color=yellow]0.0%s[/color]" % suffix

		if not is_equal_approx(compare_val, base_val):
			var diff: float = base_val - compare_val

			var diff_sign: String = "+" if diff > 0 else ""
			var diff_string: String = "%s%.2f%s" % [diff_sign, diff, suffix]

			var color: String = "red"
			if diff > 0:
				color = "green"
			var formatted_diff: String = "[color=%s]%s[/color]" % [color, diff_string]

			description_lines.append("%s: %s" % [current_label_text, formatted_diff])

	return "\n".join(description_lines)

func set_item_data(_display_item: Resource, _compare_item: BaseResource = null) -> void:
	if not (_display_item is BaseResource or _display_item is UpgradeResource):
		if _display_item == null:
			push_error("Item is null")
		push_error("Item is not of appropriate type (BaseResource/UpgradeResource), but instead: ", _display_item.get_class())
		return

	shop_item = _display_item
	compare_item = _compare_item

func populate_visual_fields() -> void:
	name_label.text = shop_item.name
	if shop_item.icon: item_icon.texture = shop_item.icon
	type_label.text = ItemEnums.item_type_to_string(shop_item.type)
	item_currency_icon.texture = prosperity_egg_icon if shop_item.currency_type == CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS else feathers_of_rebirth_icon
	item_cost_label.text = str(shop_item.cost)
	
	if compare_item:
		currency_container.visible = true
		description_label.text = _create_compare_item_description()
	else:
		currency_container.visible = false
		description_label.text = "\n".join(shop_item.get_modifier_string())
