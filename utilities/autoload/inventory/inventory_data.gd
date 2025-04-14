## Resource for saving and loading inventory data
class_name InventoryData
extends Resource

## All inventory items
@export var items: Array[BaseResource] = []

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

func _init(
	_items: Array[BaseResource] = [],
	_melee_weapon_slot: MeleeWeaponResource = null,
	_ranged_weapon_slot: RangedWeaponResource = null,
	_ability_slot_one: AbilityResource = null,
	_ability_slot_two: AbilityResource = null
) -> void:
	items = _items
	melee_weapon_slot = _melee_weapon_slot
	ranged_weapon_slot = _ranged_weapon_slot
	ability_slot_one = _ability_slot_one
	ability_slot_two = _ability_slot_two

## Validates if an item can be equipped (must be in inventory or null)
func _validate_slot(item: BaseResource, slot_name: String) -> BaseResource:
	if item == null || items.has(item):
		return item
	push_error("%s not in inventory!" % slot_name)
	return null
