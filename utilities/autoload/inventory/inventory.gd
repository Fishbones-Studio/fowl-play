## Autoload script to manage the inventory
extends Node

## Saving the inventory to a resource file on the user's system
const SAVE_FILE_PATH : String = "user://inventory_save.tres"

var items_in_inventory: Array[BaseResource] = []


func _ready() -> void:
	# Loading the inventory when the game starts
	load_inventory()
	pass


## Add an item to the player's inventory
func add_item(item: BaseResource) -> void:
	print("Adding item to inventory: ", item)
	items_in_inventory.append(item)
	save_inventory()


## Get all items from the player's inventory
func get_items() -> Array[BaseResource]:
	return items_in_inventory
	

## Get all items with the same type
func get_item_by_type(item_type: ItemEnums.ItemTypes) -> Array[BaseResource]:
	var matching_items: Array[BaseResource] = []
	
	for item in items_in_inventory:
		if item.type == item_type:
			matching_items.append(item)
	
	return matching_items


func remove_item(item: BaseResource) -> void:
	items_in_inventory = items_in_inventory.filter(func(i): return i != item)
	save_inventory()


func save_inventory() -> void:
	var inventory_data = InventoryData.new() # creating a new instance of InventoryData resource
	inventory_data.items = items_in_inventory.duplicate(true) # Deep copy, aka clone. duplicate(false) would be a shallow copy, aka reference copy

	var error: int = ResourceSaver.save(inventory_data, SAVE_FILE_PATH)
	if error != OK:
		printerr("Failed to save inventory. Error code: ", error)


func load_inventory() -> void:
	if ResourceLoader.exists(SAVE_FILE_PATH):
		var inventory_data: InventoryData = ResourceLoader.load(SAVE_FILE_PATH)
		items_in_inventory = inventory_data.items.duplicate(true) # Deep copy, aka clone. duplicate(false) would be a shallow copy, aka reference copy
		print("Inventory loaded successfully, with: " + str(items_in_inventory.size()) + " items")
	else:
		print("No inventory save file found, starting fresh")
