## Autoload script to manage all items in the game. Will excist of a dict of all
## items and a function to get a random item.
extends Node

const ITEM_ENUMS = preload("uid://3mucjbtp3r4g")

var items: Array[Resource] = []


func _ready() -> void:
	_load_items("res://resources/melee_weapons/")
	_load_items("res://resources/ranged_weapons/")
	_load_items("res://resources/passives/")
	_load_items("res://resources/abilities/")
	
	for item in items:
		print("Loaded item: ", item.name, " with type: ", item_type_to_string(item.type))


## Get a random item based on the item´s drop chance
func get_random_item() -> Resource:
	# Calculate total drop chance
	var total_drop_chance = 0
	for item in items:
		total_drop_chance += item.drop_chance
	
	# Roll a random number between 0 and the total drop chance
	var roll: int = randi() % total_drop_chance
	var cumulative: int = 0
	
	# Find the item corresponding to the roll
	for item in items:
		cumulative += item.drop_chance
		if roll < cumulative:
			return item
	
	return null


## Helper function to convert the enum to a readable string
func item_type_to_string(item_type: int) -> String:
	match item_type:
		ITEM_ENUMS.ItemTypes.WEAPON:
			return "Weapon"
		ITEM_ENUMS.ItemTypes.RANGED_WEAPON:
			return "Ranged Weapon"
		ITEM_ENUMS.ItemTypes.BOOTS:
			return "Boots"
		ITEM_ENUMS.ItemTypes.HELMET:
			return "Helmet"
		ITEM_ENUMS.ItemTypes.ABILITY:
			return "Ability"
	return "Unknown"  # Fallback if the type is not recognized	


func _load_items(path: String):
	var files = DirAccess.get_files_at(path)
	
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
