## Resource for saving and loading inventory data
class_name InventoryData
extends Resource

## All inventory items
@export_group("items")
@export var items: Array[BaseResource] = []

## Bool to trigger recalculation of items_sorted
var recalc_items_sorted: bool = true
## Sorted inventory
var items_sorted_flattened : Array :
	get: 
		if items_sorted_flattened == null or recalc_items_sorted:
			items_sorted_flattened = _get_items_sorted_flattened()
			recalc_items_sorted = false
		return items_sorted_flattened

## Inventory slots (can be null/empty)
@export var melee_weapon_slot: MeleeWeaponResource:
	set(value):
		melee_weapon_slot = _validate_slot(value, "Melee Weapon")
@export var ranged_weapon_slot: RangedWeaponResource:
	set(value):
		ranged_weapon_slot = _validate_slot(value, "Ranged Weapon")
@export var ability_slot_one: AbilityResource:
	set(value):
		ability_slot_one = _validate_slot(value, "Ability One")
@export var ability_slot_two: AbilityResource:
	set(value):
		ability_slot_two = _validate_slot(value, "Ability Two")


## Validates if an item can be equipped (must be in inventory or null)
func _validate_slot(item: BaseResource, slot_name: String) -> BaseResource:
	if item == null or items.has(item):
		return item
	push_error("%s not in inventory!" % slot_name)
	return null


## Returns a flat array of all items sorted by their type
func _get_items_sorted_flattened() -> Array:
	# Get the sorted items
	var sorted_items : Dictionary[ItemEnums.ItemTypes, Array] = get_items_sorted()
	# Flatten the dictionary values into a single array
	var flattened_items: Array = []
	for item_list in sorted_items.values():
		flattened_items += item_list
	return flattened_items


## Returns a list of items sorted by their type, first melee, then ranged, then abilities
func get_items_sorted() -> Dictionary[ItemEnums.ItemTypes, Array]:
	# Create a dictionary to hold the sorted items
	var sorted_items: Dictionary[ItemEnums.ItemTypes, Array] = {
		ItemEnums.ItemTypes.MELEE_WEAPON: [],
		ItemEnums.ItemTypes.RANGED_WEAPON: [],
		ItemEnums.ItemTypes.ABILITY: []
	}

	# Iterate through the items and sort them by type
	for item in items:
		if item.type in sorted_items:
			sorted_items[item.type].append(item)
		else:
			push_warning("Unknown item type: ", item.type)

	return sorted_items
