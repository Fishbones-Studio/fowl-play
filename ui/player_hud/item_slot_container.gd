extends HBoxContainer

# Preloaded scenes for item slots and controller icons
const ITEM_SLOT: PackedScene = preload("uid://ckypq3131wkcv")
const ITEM_CONTROLLER_ICON_SLOT: PackedScene = preload("uid://yq62iccynmnp")

func _ready() -> void:
	# Connect to signal that activates an item slot
	SignalManager.activate_item_slot.connect(
		func(item: BaseResource):
			# Find item index in inventory
			var index : int = Inventory.inventory_data.items_sorted_flattened.find(item)
			
			print("Activating item slot at index: ", index)
			# Validate index
			if index < 0 or index >= int(get_child_count() / 2.0):
				push_warning("Invalid item slot index: ", index)
				return
				
			# Get the item slot and controller slot
			var item_slot: UiItemSlot = get_child(index * 2) as UiItemSlot
			var controller_slot: Control = get_child(index * 2 + 1) as Control
			if item_slot and controller_slot:
				# Activate the slot and show controller icon
				item_slot.active = true
				controller_slot.visible = true
				controller_slot.input_action = "attack"
				controller_slot.show_switch_icon = false
				controller_slot.show_hold_label = _should_show_hold_label(item)
				print("Activated item slot: ", item_slot)
			else:
				push_warning("No item slot found at index: ", index)
	)

	# Connect to signal that deactivates an item slot
	SignalManager.deactivate_item_slot.connect(
		func(item: BaseResource):
			var index : int = Inventory.inventory_data.items_sorted_flattened.find(item)
			if index < 0 or index >= int(get_child_count() / 2.0):
				return
				
			var item_slot: UiItemSlot = get_child(index * 2) as UiItemSlot
			var controller_slot: Control = get_child(index * 2 + 1) as Control
			if item_slot and controller_slot:
				item_slot.active = false
				controller_slot.visible = true
				controller_slot.input_action = _get_input_action_for_item(item)
				controller_slot.show_hold_label = false
				controller_slot.show_switch_icon = _should_show_switch_icon(item)
	)

	# Connect to signal that starts cooldown on an item slot
	SignalManager.cooldown_item_slot.connect(
		func(item: BaseResource, cd: float, should_create_tween : bool):
			var index: int = Inventory.inventory_data.items_sorted_flattened.find(item)
			if index < 0 or index >= int(get_child_count() / 2.0):
				return
			var item_slot: UiItemSlot = get_child(index * 2) as UiItemSlot
			if item_slot:
				item_slot.start_cooldown(cd, should_create_tween)
	)

	# Initialize all item slots
	_init_item_slots(Inventory.inventory_data.items_sorted_flattened)


# Returns the appropriate input action for the given item
func _get_input_action_for_item(item: BaseResource) -> String:    
	# Get all equipped items of different types
	var melee_items = Inventory.get_equipped_items(ItemEnums.ItemTypes.MELEE_WEAPON)
	var ranged_items = Inventory.get_equipped_items(ItemEnums.ItemTypes.RANGED_WEAPON)
	var ability_0 = Inventory.get_equipped_item(ItemEnums.ItemTypes.ABILITY, 0)
	var ability_1 = Inventory.get_equipped_item(ItemEnums.ItemTypes.ABILITY, 1)

	# Determine input action based on item type and state
	if item in melee_items or item in ranged_items:
		var item_slot := _get_item_slot_for_item(item)
		if item_slot and item_slot.active:
			return "attack"
		else:
			return "switch_weapon"
	elif item == ability_0:
		return "ability_one"
	elif item == ability_1:
		return "ability_two"
	return ""


# Finds and returns the item slot UI element for a given item
func _get_item_slot_for_item(item: BaseResource) -> UiItemSlot:
	var index := Inventory.inventory_data.items_sorted_flattened.find(item)
	if index >= 0 and index * 2 < get_child_count():
		return get_child(index * 2) as UiItemSlot
	return null


# Determines whether to show "hold" label for an item
func _should_show_hold_label(item: BaseResource) -> bool:
	if item == null:
		return false
	var ranged_items = Inventory.get_equipped_items(ItemEnums.ItemTypes.RANGED_WEAPON)
	return item in ranged_items and item.allow_continuous_fire


func _should_show_switch_icon(item: BaseResource) -> bool:
	if item == null:
		return false
	return _get_input_action_for_item(item) == "switch_weapon"


# Initializes all item slots in the UI
func _init_item_slots(items: Array) -> void:
	for i in range(items.size()):
		var item = items[i]
		if not item is BaseResource:
			continue

		# Create new item slot and controller icon
		var item_slot := ITEM_SLOT.instantiate() as UiItemSlot
		var controller_slot := ITEM_CONTROLLER_ICON_SLOT.instantiate() as Control
		if not item_slot or not controller_slot:
			continue

		# Add to scene and configure
		add_child(item_slot)
		add_child(controller_slot)
		item_slot.item = item

		# Set up controller icon properties
		controller_slot.input_action = _get_input_action_for_item(item)
		controller_slot.show_hold_label = _should_show_hold_label(item)
		controller_slot.show_switch_icon = _should_show_switch_icon(item)
