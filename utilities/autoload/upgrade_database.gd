## Autoload script to manage all the upgrades in the game. Will excist of a dict of all
## items and a function to get a random upgrade.
extends Node

const ITEM_ENUMS = preload("uid://3mucjbtp3r4g")
var items: Array[Resource] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_items("res://resources/in_run_upgrades/")

	for item in items:
		print("Loaded item: ", item.name, " with type: ", item_type_to_string(item.type))

func get_random_item() -> Resource:
	# Calculate total drop chance
	var total_drop_chance: int = 0
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
func item_type_to_string(item_type: ItemEnums.ItemTypes) -> String:
	var item_string: String = ItemEnums.ItemTypes.keys()[item_type]
	# Turn item_string from UPPER_CASE to Title Case
	return item_string.capitalize()


func _load_items(path: String) -> void:
	var files: PackedStringArray = DirAccess.get_files_at(path)

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
