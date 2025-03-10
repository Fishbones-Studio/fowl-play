extends Control
class_name Item_Template
@onready var item_name: Label = $VBoxContainer/item_name
@onready var item_cost: Label = $VBoxContainer/item_cost
@onready var item_type: Label = $VBoxContainer/item_type

func set_item(item):
	item_name.text = item.name
	item_type.text = item.type
	item_cost.text = str(item.cost)
	
	


func _on_buy_item_pressed() -> void:
	if Gamemanager.prosperity_eggs >= int(item_cost.text):
		Gamemanager.Update_ProsperityEggs(-int(item_cost.text))
	
		
