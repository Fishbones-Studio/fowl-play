extends Control
class_name Item_Template
@onready var item_name: Label = $VBoxContainer/item_name
@onready var item_cost: Label = $VBoxContainer/item_cost

func set_item(item):
	item_name.text = item.name
	item_cost.text = str(item.cost)
