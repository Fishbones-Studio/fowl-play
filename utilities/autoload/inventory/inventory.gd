## Autoload script to manage player inventory and equipment
extends Node

## Constants
const SAVE_FILE_PATH: String = "user://inventory_save.tres"

## Configuration
var default_slot_config: Dictionary[ItemEnums.ItemTypes, int] = {
	ItemEnums.ItemTypes.MELEE_WEAPON: 1,
	ItemEnums.ItemTypes.RANGED_WEAPON: 1,
	ItemEnums.ItemTypes.ABILITY: 2
}

## State
var inventory_data: InventoryData:
	set(value):
		_set_default_items(value)
		inventory_data = value


func _ready() -> void:
	load_inventory()


## Function to validate if an item can be equipped
func _validate_equipment_operation(item: BaseResource, slot_index: int) -> bool:
	var slot_type: ItemEnums.ItemTypes = item.type

	if slot_index < 0 or slot_index >= default_slot_config.get(slot_type, 0):
		push_warning("Invalid slot index ", slot_index, " for type ", slot_type)
		return false

	return true


func _set_default_items(loaded: InventoryData) -> void:
	if loaded.melee_weapon_slot == null:
		var default_melee_weapon: BaseResource = ResourceLoader.load(
			"uid://c6srj1sb1gdhm"
		)
		# Ensure item is in the main list before equipping
		if not loaded.items.has(default_melee_weapon):
			loaded.items.append(default_melee_weapon)
		loaded.melee_weapon_slot = default_melee_weapon


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

	# We might be unequipping an item that's no longer valid for the slot (e.g. data corruption or game logic change)
	if !_validate_equipment_operation(item, slot_index):
		# If item is not in a valid slot according to its type, check if it's actually equipped there.
		# This handles cases where an item might be in a slot it shouldn't be due to prior state.
		var currently_equipped: BaseResource = get_equipped_item(slot_type, slot_index)
		if currently_equipped != item:
			push_warning(
				"Item ",
				item.name,
				" not found in specified slot ",
				slot_index,
				" for type ",
				slot_type,
				" during unequip attempt."
			)
			return false

	match slot_type:
		ItemEnums.ItemTypes.MELEE_WEAPON:
			if inventory_data.melee_weapon_slot == item:
				inventory_data.melee_weapon_slot = null
			else: return false # Item not in this specific slot
		ItemEnums.ItemTypes.RANGED_WEAPON:
			if inventory_data.ranged_weapon_slot == item:
				inventory_data.ranged_weapon_slot = null
			else: return false
		ItemEnums.ItemTypes.ABILITY:
			if slot_index == 0 and inventory_data.ability_slot_one == item:
				inventory_data.ability_slot_one = null
			elif slot_index == 1 and inventory_data.ability_slot_two == item:
				inventory_data.ability_slot_two = null
			else:
				# If slot_index was valid but item doesn't match, or index was bad.
				push_error(
					"Failed to unequip ability: item not in specified slot or invalid slot index ",
					slot_index
				)
				return false
		_:
			push_error("Unknown item type for unequip: ", item.type)
			return false
	return true


## Equipment Management
func equip_item(item: BaseResource, slot_index: int = -1) -> bool:
	if not inventory_data or not inventory_data.items.has(item):
		push_error("Cannot equip item not in inventory: ", item.name)
		return false

	# Auto-find first available slot if none specified
	if slot_index == -1:
		var num_slots_for_type = default_slot_config.get(item.type, 0)
		for i in num_slots_for_type:
			if get_equipped_item(item.type, i) == null:
				slot_index = i
				break
		if slot_index == -1: # Still -1 means no slot was found
			push_warning("No available equip slots for item type: ", item.type)
			return false

	if _equip_item_in_slot(item, slot_index):
		save_inventory()
		return true
	else:
		push_error("Failed to equip item: ", item.name, " in slot index: ", slot_index)
		return false


func unequip_item(item: BaseResource, slot_index: int = -1) -> bool:
	if not inventory_data:
		push_error("Inventory data not initialized, cannot unequip item.")
		return false

	var item_type: ItemEnums.ItemTypes = item.type
	var unequipped_successfully: bool  = false

	if slot_index != -1: # Specific slot provided
		if _unequip_item_from_slot(item, slot_index):
			unequipped_successfully = true
	else: # No specific slot, find the item and unequip
		var num_slots_for_type = default_slot_config.get(item_type, 0)
		for i in num_slots_for_type:
			if get_equipped_item(item_type, i) == item:
				if _unequip_item_from_slot(item, i):
					unequipped_successfully = true
					break # Found and unequipped
		if not unequipped_successfully:
			push_warning(
				"Item ", item.name, " not found in any equip slot to unequip."
			)
			return false # Item wasn't equipped or couldn't be unequipped

	if unequipped_successfully:
		save_inventory() # Save after successful unequip
		return true
	else:
		# Error message would have been printed by _unequip_item_from_slot or above
		return false


func get_equipped_item(
	item_type: ItemEnums.ItemTypes,
	slot_index: int
) -> BaseResource:
	if not inventory_data: return null

	match item_type:
		ItemEnums.ItemTypes.MELEE_WEAPON:
			if slot_index == 0: return inventory_data.melee_weapon_slot
		ItemEnums.ItemTypes.RANGED_WEAPON:
			if slot_index == 0: return inventory_data.ranged_weapon_slot
		ItemEnums.ItemTypes.ABILITY:
			if slot_index == 0:
				return inventory_data.ability_slot_one
			elif slot_index == 1:
				return inventory_data.ability_slot_two

		_:
			pass
	push_warning(
		"Invalid type or slot index for get_equipped_item: Type ",
		item_type,
		", Slot ",
		slot_index
	)
	return null

func get_equipped_items(item_type: ItemEnums.ItemTypes) -> Array[BaseResource]:
	var result: Array[BaseResource] = []
	if not inventory_data: return result

	match item_type:
		ItemEnums.ItemTypes.MELEE_WEAPON:
			if inventory_data.melee_weapon_slot != null:
				result.append(inventory_data.melee_weapon_slot)
		ItemEnums.ItemTypes.RANGED_WEAPON:
			if inventory_data.ranged_weapon_slot != null:
				result.append(inventory_data.ranged_weapon_slot)
		ItemEnums.ItemTypes.ABILITY:
			if inventory_data.ability_slot_one != null:
				result.append(inventory_data.ability_slot_one)
			if inventory_data.ability_slot_two != null:
				result.append(inventory_data.ability_slot_two)
		_:
			push_error("Unknown item type for get_equipped_items: ", item_type)

	return result


## Inventory Queries
func add_item(
	item: BaseResource,
	slot_index: int = -1,
	auto_equip: bool = true
) -> void:
	if not inventory_data:
		inventory_data = InventoryData.new() # Initialize if null, setter handles defaults
		print("InventoryData was null, initialized new one.")

	if inventory_data.items.has(item):
		push_warning("Item already in inventory: ", item.name)
		return

	inventory_data.items.append(item)

	if auto_equip:
		print("Attempting to auto-equip item: ", item.name)
		equip_item(item, slot_index) # equip_item handles save_inventory

	save_inventory() # Save even if not equipped, because item was added


func remove_item(item: BaseResource) -> void:
	if not inventory_data or not inventory_data.items.has(item):
		push_warning("Item not in inventory, cannot remove: ", item.name)
		return

	# Unequip the item from all possible slots it might be in
	var item_type: ItemEnums.ItemTypes = item.type
	var num_slots_for_type             = default_slot_config.get(item_type, 0)
	for i in num_slots_for_type:
		if get_equipped_item(item_type, i) == item:
			unequip_item(item, i) # unequip_item handles save_inventory

	inventory_data.items.erase(item)
	save_inventory() # Save after removing from list and unequipped


func get_all_items() -> Array[BaseResource]:
	if not inventory_data: return []
	return inventory_data.items.duplicate(true)


func get_all_items_sorted() -> Dictionary[ItemEnums.ItemTypes, Array]:
	if not inventory_data: return {}
	return inventory_data.get_items_sorted().duplicate(true)


func get_items_by_type(item_type: ItemEnums.ItemTypes) -> Array[BaseResource]:
	if not inventory_data: return []
	return inventory_data.items.filter(
		func(item_resource): return item_resource.type == item_type
	)


## Inventory Management
func save_inventory() -> void:
	if not inventory_data:
		push_error("Cannot save inventory, inventory_data is null.")
		return
	inventory_data.recalc_items_sorted = true # Force recalculation of sorted items on next get
	var error: int = ResourceSaver.save(inventory_data, SAVE_FILE_PATH)
	if error != OK:
		push_error("Inventory save failed with error code: ", error)


func load_inventory() -> void:
	if ResourceLoader.exists(SAVE_FILE_PATH):
		var loaded: Resource = ResourceLoader.load(SAVE_FILE_PATH)
		if loaded is InventoryData:
			inventory_data = loaded # Setter calls _set_default_items
			print("Loaded inventory with %d items" % inventory_data.items.size())
			return
		else:
			push_warning(
				"Inventory save file found at '%s', but it's not a valid InventoryData resource. Creating new."
				% SAVE_FILE_PATH
			)

	# If file doesn't exist or was invalid
	push_warning(
		"No valid inventory save file found at '%s', creating a new one."
		% SAVE_FILE_PATH
	)
	inventory_data = InventoryData.new() # Setter calls _set_default_items
	print("Created new default inventory.")
	save_inventory() # Save the newly created default inventory immediately


func reset_inventory() -> void:
	print("Resetting inventory to default state (soft reset)...")
	inventory_data = InventoryData.new() # This triggers the setter, which calls _set_default_items
	save_inventory() # Save the new default state
	print("Inventory reset and saved.")


func hard_reset_inventory() -> void:
	print("Performing hard reset of inventory data...")

	# Delete the physical save file
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var global_path_for_removal: String = ProjectSettings.globalize_path(
			SAVE_FILE_PATH
		)
		var err: Error = DirAccess.remove_absolute(global_path_for_removal)
		if err == OK:
			print(
				"Inventory save file deleted successfully: %s" % global_path_for_removal
			)
		else:
			push_error(
				"Failed to delete inventory save file '%s'. Error: %s."
				% [global_path_for_removal, error_string(err)]
			)
	else:
		print(
			"No inventory save file found to delete at: %s. A new default inventory will be created."
			% SAVE_FILE_PATH
		)

	# Manual reset the inventory data
	inventory_data = InventoryData.new()
	save_inventory()

	print(
		"Inventory hard reset complete. Inventory is now at initial default state."
	)
