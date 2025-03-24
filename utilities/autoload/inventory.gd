extends Node
## Autoload script to manage the inventory

var items_in_inventory: Array[Resource] = []


## Add an item to the player's inventory
func add_item(item: Resource) -> void:
	items_in_inventory.append(item)


## Get all items from the player's inventory
func get_items() -> Array[Resource]:
	return items_in_inventory


## Get an item based on the name, else return null
func get_item_by_name(item_name: String) -> Resource:
	for item in items_in_inventory:
		if item.name == item_name:
			print("item found: ", item)
			return item
	
	return null


## Get all items with the same type
func get_item_by_type(item_type: ItemEnums.ItemTypes) -> Array[Resource]:
	var matching_items: Array[Resource] = []
	
	for item in items_in_inventory:
		if item.type == item_type:
			matching_items.append(item)
	
	return matching_items


func remove_item(item: Resource) -> void:
	items_in_inventory = items_in_inventory.filter(func(i): return i != item)
