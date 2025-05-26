class_name CurrencyOverview
extends CenterContainer

@onready var label_container: HBoxContainer = %LabelContainer
@onready var currency_overview_item_resource: PackedScene = preload("uid://chcpdmtyutre6")
@onready var label: Label = $VBoxContainer/Label


func update_label_container(currency_dict: Dictionary) -> void:
	for child in label_container.get_children():
		label_container.remove_child(child)
		child.queue_free()

	visible = not currency_dict.is_empty()

	for key in currency_dict:
		var currency_overview_item: CurrencyOverviewItem = currency_overview_item_resource.instantiate()
		label_container.add_child(currency_overview_item)
		currency_overview_item.icon.texture = currency_overview_item.icons[key]
		currency_overview_item.amount.text = str(currency_dict[key])
		currency_overview_item.label.text = CurrencyEnums.type_to_string(key)
