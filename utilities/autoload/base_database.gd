## Base class for all shop databases in the game
class_name BaseDatabase
extends Node

const ITEM_ENUMS = preload("uid://3mucjbtp3r4g")

var items: Array[Resource] = []


# Child classes should override this to load their specific resources
func _load_resources() -> void:
	pass


func _ready() -> void:
	_load_resources()
	
	for item in items:
		print("Loaded item: ", item.name, " with type: ", item_type_to_string(item.type))


## Get a random item based on the item´s drop chance
func get_random_item() -> Resource:
	# Calculate total drop chance
	var total_drop_chance: int = 0
	for item in items:
		total_drop_chance += item.drop_chance
	
	# Roll a random number between 1 and the total drop chance. You can not modulo by 0
	var roll = randi() % max(1, total_drop_chance)
	var cumulative: int = 0
	
	# Find the item corresponding to the roll
	for item in items:
		cumulative += item.drop_chance
		if roll < cumulative:
			return item
	
	return null


## Helper function to convert the enum to a readable string
func item_type_to_string(item_type: ItemEnums.ItemTypes) -> String:
	var item_string: String = ItemEnums.ItemTypes.keys()[item_type]
	# Turn item_string from UPPER_CASE to Title Case
	return item_string.capitalize()


func _load_items(path: String) -> void:
	var files: PackedStringArray = ResourceLoader.list_directory(path)
	
	if not files:
		print("An error occurred when trying to access path: ", path)
		return
	
	for file in files:
		if file.ends_with(".tres"):
			items.append(load(path + file))


## Find an item in the database based on item name
func get_item_by_name(item_name: String) -> Resource:
	for item in items:
		if item.name == item_name:
			return item
	
	print("Item with name '", item_name, "' not found in the database")
	return null


## Find an item in the database based on it's resource
func get_item(item_res: Resource) -> Resource:
	for item in items:
		if item == item_res:
			return item
	
	print("Item '", item_res, "' not found in the database")
	return null
