extends Node
#Autoload script to manage the inventory
var items_in_inventory: Array = []

func add_item(item):
	items_in_inventory.append(item)

	
func get_items():
	return items_in_inventory
	
#Function to check if an item with x name already exists
func get_item_by_name(item_name):
	for item in items_in_inventory:
		if item.name == item_name:
			print("item found: ", item)
			return item
	return null
	
#Function to return all items with a certain type
func get_item_by_type(item_type):
	var matching_items = []
	
	for item in items_in_inventory:
		if item.type == item_type:
			matching_items.append(item)
			
	if item_type == "Ability"  and matching_items.size() == 2:
		return matching_items
	return matching_items if matching_items.size() > 0 else []
	
func remove_item_by_type(item_type):
	items_in_inventory = items_in_inventory.filter(func(i): return i.type != item_type)

func remove_item(item):
	items_in_inventory = items_in_inventory.filter(func(i): return i != item)
		
				

		
	
