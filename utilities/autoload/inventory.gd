extends Node
#Autoload script to manage the inventory

var items_in_inventory: Array = []

func add_item(item):
<<<<<<< HEAD
	items_in_inventory.append(item)
=======
	if typeof(item) == TYPE_DICTIONARY:
		items_in_inventory.append(item)
	else:
		print("Invalid item format")
>>>>>>> b935991e8e5dcb9e7b4ec4e6248e80e321c6e850

	
func get_items() -> Array:
	return items_in_inventory
<<<<<<< HEAD
	
#Function to check if an item with x name already exists
func get_item_by_name(item_name):
=======


func get_item_by_name(item_name) -> Variant:

>>>>>>> b935991e8e5dcb9e7b4ec4e6248e80e321c6e850
	for item in items_in_inventory:
		if item.name == item_name:
			print("item found: ", item)
			return item
	return null
	
<<<<<<< HEAD
#Function to return all items with a certain type
func get_item_by_type(item_type):
	var matching_items = []
=======

func get_item_by_type(item_type) -> Array[Variant]:
	var matching_items: Array[Variant] = []

>>>>>>> b935991e8e5dcb9e7b4ec4e6248e80e321c6e850
	
	for item in items_in_inventory:
		if item.type == item_type:
			matching_items.append(item)

			
	if item_type == "Ability"  and matching_items.size() == 2:
		return matching_items
	return matching_items if matching_items.size() > 0 else []
<<<<<<< HEAD
=======

func remove_item_by_type(item_type):
	items_in_inventory = items_in_inventory.filter(func(i): return i.type != item_type)
>>>>>>> b935991e8e5dcb9e7b4ec4e6248e80e321c6e850

func remove_item(item):
	items_in_inventory = items_in_inventory.filter(func(i): return i != item)

	
