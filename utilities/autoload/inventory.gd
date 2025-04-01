extends Node
## Autoload script to manage the inventory
const SAVE_FILE_PATH : String = "user://inventory_save.json"
var items_in_inventory: Array[Resource] = []


## Add an item to the player's inventory
func add_item(item: Resource) -> void:
	items_in_inventory.append(item)
	save_intentory()


## Get all items from the player's inventory
func get_items() -> Array[Resource]:
	return items_in_inventory


## Get an item based on the name, else return null
func get_item_by_name(item_name: String) -> Resource:
	for item in items_in_inventory:
		if item.name == item_name:
			print("item found: ", item)
			return item
	print("Item not found:", item_name)
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
	save_inventory()

#Function to save inventory
func save_inventory() -> void:
	var save_data: Dictionary = {"items": []}
	
	#Place iventory items into save_data
	for item in items_in_inventory:
		if item.resource_path != "":
			save_data["items"].append(item.resource_path)
		else:
			print("WARNING: Item has no resource path!", item)
	#Write save_data to a file
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("Inventory Saved! ", save_data)
	
func load_inventory() -> void:
	# Check if file exists
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found. ")
		return
	#Store all items into save_data
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var save_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if not save_data or not "items" in save_data:
		print("Failed to load inventory data.")
		return
		
	items_in_inventory.clear()
	#Loop save_data for all items and add them to the inventory
	for item_path in save_data["items"]:
		if ResourceLoader.exists(item_path):
			var item = load(item_path) as Resource
			items_in_inventory.append(item)
		else:
			print("WARNING: Item resource not found:", item_path)
			
	print("Inventory Loaded! ", get_items())
			
				
