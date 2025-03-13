extends Node

var items_in_inventory: Array = []

func add_item(item: Dictionary):
	items_in_inventory.append(item)
	
func get_items():
	return items_in_inventory
	
func get_item_by_type(item_type : String):
	for item in items_in_inventory:
		if item.type == item_type:
			return item
	return null
	
func remove_item_by_type(item_type : String):
	items_in_inventory = items_in_inventory.filter(func(i): return i.type != item_type)
