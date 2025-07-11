## Base class for all shop databases in the game
class_name BaseDatabase
extends Node

# Child classes should override this to load their specific resources
static func _load_resources() -> Array[BaseResource]:
	return []

var items: Array[BaseResource] = []

func _ready() -> void:
	items = _load_resources()
	for item in items:
		print("Loaded item: ", item.name, " with type: ", ItemEnums.item_type_to_string(item.type))


## Get a random item based on the item´s drop chance
func get_random_item() -> BaseResource:
	# Calculate total drop chance
	var total_drop_chance: int = 0
	for item in items:
		total_drop_chance += item.drop_chance

	# Roll a random number between 1 and the total drop chance. You can not modulo by 0
	var roll: float = randi() % max(1, total_drop_chance)
	var cumulative: float = 0

	# Find the item corresponding to the roll
	for item in items:
		var item_drop_chance: float = item.drop_chance
		if item_drop_chance == 0:
			continue
		cumulative += item_drop_chance
		if roll < cumulative:
			return item

	return null


static func get_files_from_path(path: String) -> PackedStringArray:
	var files: PackedStringArray = ResourceLoader.list_directory(path)

	if not files:
		push_error("An error occurred when trying to access path: ", path)

	return files


static func load_items(path: String) -> Array[BaseResource]:
	var files: PackedStringArray = get_files_from_path(path)
	var temp_items: Array[BaseResource] = []

	for file in files:
		if file.ends_with(".tres"):
			var file_path: String = path.path_join(file)
			var resource: Resource = load(file_path)
			if resource is BaseResource:
				temp_items.append(resource)
			else:
				push_warning("File '", file, "' is not a BaseResource")

	return temp_items


## Find an item in the database based on item name
func get_item_by_name(item_name: String) -> Resource:
	for item in items:
		if item.name == item_name:
			return item

	print("Item with name '", item_name, "' not found in the database")
	return null


## Find an item in the database based on it's resource
func get_item(item_res: Resource) -> BaseResource:
	for item in items:
		if item == item_res:
			return item

	print("Item '", item_res, "' not found in the database")
	return null
