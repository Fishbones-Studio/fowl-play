## Autoload script to manage player inventory and equipment
extends Node

## Constants
const SAVE_FILE_PATH := "user://inventory_save.tres"

## Configuration
var default_slot_config: Dictionary[ItemEnums.ItemTypes, int] = {
		ItemEnums.ItemTypes.MELEE_WEAPON: 1,
		ItemEnums.ItemTypes.RANGED_WEAPON: 1,
		ItemEnums.ItemTypes.ABILITY: 2
	}

## State
var inventory_data: InventoryData


func _ready() -> void:
	load_inventory()
	GameManager.prosperity_eggs_changed.connect(
		func(value): 
			print("Setting prosperity eggs  in save system to: ", value)
			inventory_data.prosperity_eggs = value
			save_inventory()
	)
	GameManager.feathers_of_rebirth_changed.connect(
		func(value): 
			inventory_data.feathers_of_rebirth = value
			save_inventory()
	)


## Function to validate if an item can be equipped
func _validate_equipment_operation(item: BaseResource, slot_index: int) -> bool:
	var slot_type: ItemEnums.ItemTypes = item.type

	if slot_index < 0 or slot_index >= default_slot_config.get(slot_type, 0):
		push_warning("Invalid slot index ", slot_index, " for type ", slot_type)
		return false

	return true


## Function for setting the correct equipment slot
func _equip_item_in_slot(item: BaseResource, slot_index: int) -> bool:
	var slot_type: ItemEnums.ItemTypes = item.type

	if !_validate_equipment_operation(item, slot_index):
		return false

	match slot_type:
		ItemEnums.ItemTypes.MELEE_WEAPON:
			inventory_data.melee_weapon_slot = item
		ItemEnums.ItemTypes.RANGED_WEAPON:
			inventory_data.ranged_weapon_slot = item
		ItemEnums.ItemTypes.ABILITY:
			if slot_index == 0:
				inventory_data.ability_slot_one = item
			elif slot_index == 1:
				inventory_data.ability_slot_two = item
			else:
				push_error("Invalid ability slot index ", slot_index)
				return false
		_:
			push_error("Unknown item type: ", item.type)
			return false
	return true


## Function to unequip an item from a slot
func _unequip_item_from_slot(item: BaseResource, slot_index: int) -> bool:
	var slot_type: ItemEnums.ItemTypes = item.type

	if !_validate_equipment_operation(item, slot_index):
		return false

	match slot_type:
		ItemEnums.ItemTypes.MELEE_WEAPON:
			inventory_data.melee_weapon_slot = null
		ItemEnums.ItemTypes.RANGED_WEAPON:
			inventory_data.ranged_weapon_slot = null
		ItemEnums.ItemTypes.ABILITY:
			if slot_index == 0:
				inventory_data.ability_slot_one = null
			elif slot_index == 1:
				inventory_data.ability_slot_two = null
			else:
				push_error("Invalid ability slot index ", slot_index)
				return false
		_:
			push_error("Unknown item type: ", item.type)
			return false
			
	return true


## Equipment Management
func equip_item(item: BaseResource, slot_index: int = -1) -> bool:
	if not inventory_data.items.has(item):
		push_error("Cannot equip item not in inventory: ", item.name)
		return false

	# Auto-find first available slot if none specified
	if slot_index == -1:
		for i in default_slot_config.get(item.type, 0):
			if get_equipped_item(item.type, i) == null:
				slot_index = i
				break
		if slot_index == -1:
			push_warning("No available equip slots for item type: ", item.type)
			return false
		
	if _equip_item_in_slot(item, slot_index):
		save_inventory()
		return true
	else:
		push_error("Failed to equip item: ", item.name, " in slot index: ", slot_index)
		return false


func unequip_item(item: BaseResource, slot_index: int = -1) -> bool:
	if slot_index == -1:
		for i in default_slot_config.get(item.type, 0):
			if get_equipped_item(item.type, i) != null:
				slot_index = i
				break
		if slot_index == -1:
			push_warning("No available unequip slots for item type: ", item.type)
			return false

	if _unequip_item_from_slot(item, slot_index):
		return true
	else:
		push_error("Failed to unequip item: ", item.name, " from slot index: ", slot_index)
		return false


func get_equipped_item(
	item_type: ItemEnums.ItemTypes,
	slot_index: int
) -> BaseResource:
	match item_type:
		ItemEnums.ItemTypes.MELEE_WEAPON:
			return inventory_data.melee_weapon_slot
		ItemEnums.ItemTypes.RANGED_WEAPON:
			return inventory_data.ranged_weapon_slot
		ItemEnums.ItemTypes.ABILITY:
			if slot_index == 0:
				return inventory_data.ability_slot_one
			elif slot_index == 1:
				return inventory_data.ability_slot_two
			else:
				push_error("Invalid ability slot index ", slot_index)
				return null
		_:
			push_error("Unknown item type: ", item_type)
			return null


## Inventory Queries
func add_item(
	item: BaseResource,
	slot_index: int = -1,
	auto_equip: bool = true
) -> void:
	if inventory_data.items.has(item):
		push_warning("Item already in inventory: ", item.name)
		return

	inventory_data.items.append(item)

	if auto_equip:
		print("Auto-equipping item: ", item.name)
		equip_item(item, slot_index)

	save_inventory()


func remove_item(item: BaseResource) -> void:
	inventory_data.items.erase(item)
	unequip_item(item)
	save_inventory()


func get_all_items() -> Array[BaseResource]:
	return inventory_data.items.duplicate(true)


func get_items_by_type(item_type: ItemEnums.ItemTypes) -> Array[BaseResource]:
	return inventory_data.items.filter(
		func(item): return item.type == item_type
	)


## Inventory Management
func save_inventory() -> void:	
	inventory_data.recalc_items_sorted = true # Force recalculation of sorted items on next get
	var error: int = ResourceSaver.save(inventory_data, SAVE_FILE_PATH)
	if error != OK:
		push_error("Inventory save failed with error code: ", error)


func load_inventory() -> void:
	if ResourceLoader.exists(SAVE_FILE_PATH):
		var loaded: Resource = ResourceLoader.load(SAVE_FILE_PATH)
		if loaded is InventoryData:
			inventory_data = loaded
			GameManager.prosperity_eggs = inventory_data.prosperity_eggs
			GameManager.feathers_of_rebirth = inventory_data.feathers_of_rebirth
			print("Loaded inventory with %d items" % inventory_data.items.size())
			return
	else:
		push_warning("No inventory save file found, creating a new one")
		inventory_data = InventoryData.new()


func reset_inventory() -> void:
	inventory_data = InventoryData.new()
	# setting the currency, since that is persistent
	inventory_data.prosperity_eggs = GameManager.prosperity_eggs
	inventory_data.feathers_of_rebirth = GameManager.feathers_of_rebirth
	save_inventory()
