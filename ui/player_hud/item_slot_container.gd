extends HBoxContainer

const ITEM_SLOT: PackedScene = preload("uid://ckypq3131wkcv")
const ITEM_CONTROLLER_ICON_SLOT: PackedScene = preload("uid://yq62iccynmnp")



func _ready() -> void:
	# Add this to ensure ALL controller slots update on keybind changes
	SignalManager.keybind_changed.connect(
		func():
			for i in range(get_child_count() / 2):
				var item_slot = get_child(i * 2) as UiItemSlot
				var controller_slot = get_child(i * 2 + 1) as Control
				if controller_slot:
					controller_slot.input_action = _get_input_action_for_item(item_slot.item)
	)
	
	SignalManager.activate_item_slot.connect(
		func(item: BaseResource):
			var index : int = Inventory.inventory_data.items_sorted_flattened.find(item)
			
			print("Activating item slot at index: ", index)
			# Check if the item slot is valid
			if index < 0 or index >= get_child_count() / 2:  # Divided by 2 since we have both slots and icons
				push_warning("Invalid item slot index: ", index)
				return
			# Activate both the item slot and its corresponding controller icon
			var item_slot: UiItemSlot = get_child(index * 2) as UiItemSlot
			var controller_slot: Control = get_child(index * 2 + 1) as Control
			if item_slot and controller_slot:
				item_slot.active = true
				controller_slot.visible = true
				controller_slot.input_action = "attack" 
				print("Activated item slot: ", item_slot)
			else:
				push_warning("No item slot found at index: ", index)
	)

	SignalManager.deactivate_item_slot.connect(
		func(item: BaseResource):
			var index : int = Inventory.inventory_data.items_sorted_flattened.find(item)
			print("Deactivating item slot at index: ", index)
			# Check if the item slot is valid
			if index < 0 or index >= get_child_count() / 2:
				return
			# Deactivate both the item slot and its corresponding controller icon
			var item_slot: UiItemSlot = get_child(index * 2) as UiItemSlot
			var controller_slot: Control = get_child(index * 2 + 1) as Control
			if item_slot and controller_slot:
				item_slot.active = false
				controller_slot.visible = true
				controller_slot.input_action = "switch_weapon" 
				print("Deactivated item slot: ", item_slot)
			else:
				push_warning("No item slot found at index: ", index)
	)
	
	SignalManager.cooldown_item_slot.connect(
		func(item: BaseResource, cd: float, create_tween : bool):
			var index: int = Inventory.inventory_data.items_sorted_flattened.find(item)
			if index < 0 or index >= get_child_count() / 2:
				return
			var item_slot: UiItemSlot = get_child(index * 2) as UiItemSlot
			if item_slot:
				item_slot.start_cooldown(cd, create_tween)
	)
	
	_init_item_slots(Inventory.inventory_data.items_sorted_flattened)



# Returns the input action based on the item's equipped type
func _get_input_action_for_item(item: BaseResource) -> String:
	if item == null:
		return ""
	
	# Check if item is equipped as melee/ranged/ability
	var melee_items = Inventory.get_equipped_items(ItemEnums.ItemTypes.MELEE_WEAPON)
	var ranged_items = Inventory.get_equipped_items(ItemEnums.ItemTypes.RANGED_WEAPON)
	var abilities = [
		Inventory.get_equipped_item(ItemEnums.ItemTypes.ABILITY, 0),
		Inventory.get_equipped_item(ItemEnums.ItemTypes.ABILITY, 1)
	]
	
	if item in melee_items or item in ranged_items:
		return "attack"    # weapon slots
	elif item == abilities[0]:  # First ability slot
		return "ability_one"
	elif item == abilities[1]:  # Second ability slot
		return "ability_two"
	else:
		return ""  # Not equipped

func _init_item_slots(items: Array) -> void:
	for i in range(items.size()):
		var item = items[i]
		if not item is BaseResource:
			continue

		# Create slots...
		var item_slot := ITEM_SLOT.instantiate() as UiItemSlot
		var controller_slot := ITEM_CONTROLLER_ICON_SLOT.instantiate() as Control
		if !item_slot or !controller_slot:
			continue
			
		add_child(item_slot)
		add_child(controller_slot)
		item_slot.item = item

		controller_slot.input_action = _get_input_action_for_item(item)
