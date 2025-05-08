extends HBoxContainer

const ITEM_SLOT: PackedScene = preload("uid://ckypq3131wkcv")
const ITEM_CONTROLLER_ICON_SLOT: PackedScene = preload("uid://yq62iccynmnp")

func _ready() -> void:
	SignalManager.keybind_changed.connect(
		func():
			for i in range(get_child_count() / 2):
				var item_slot = get_child(i * 2) as UiItemSlot
				var controller_slot = get_child(i * 2 + 1) as Control
				if controller_slot:
					controller_slot.input_action = _get_input_action_for_item(item_slot.item)
					controller_slot.show_hold_label = _should_show_hold_label(item_slot.item)
					controller_slot.visible = true 
	)

	SignalManager.activate_item_slot.connect(
		func(item: BaseResource):
			var index : int = Inventory.inventory_data.items_sorted_flattened.find(item)
			
			print("Activating item slot at index: ", index)
			if index < 0 or index >= get_child_count() / 2:
				push_warning("Invalid item slot index: ", index)
				return
				
			var item_slot: UiItemSlot = get_child(index * 2) as UiItemSlot
			var controller_slot: Control = get_child(index * 2 + 1) as Control
			if item_slot and controller_slot:
				item_slot.active = true
				controller_slot.visible = true
				controller_slot.input_action = "attack"
				controller_slot.show_hold_label = _should_show_hold_label(item)
				print("Activated item slot: ", item_slot)
			else:
				push_warning("No item slot found at index: ", index)
	)

	SignalManager.deactivate_item_slot.connect(
		func(item: BaseResource):
			var index : int = Inventory.inventory_data.items_sorted_flattened.find(item)
			print("Deactivating item slot at index: ", index)
			if index < 0 or index >= get_child_count() / 2:
				return
				
			var item_slot: UiItemSlot = get_child(index * 2) as UiItemSlot
			var controller_slot: Control = get_child(index * 2 + 1) as Control
			if item_slot and controller_slot:
				item_slot.active = false
				controller_slot.visible = true
				controller_slot.input_action = "switch_weapon"
				controller_slot.show_hold_label = false
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


func _get_input_action_for_item(item: BaseResource) -> String:
	if item == null:
		return ""
	
	var melee_items = Inventory.get_equipped_items(ItemEnums.ItemTypes.MELEE_WEAPON)
	var ranged_items = Inventory.get_equipped_items(ItemEnums.ItemTypes.RANGED_WEAPON)
	var ability_0 = Inventory.get_equipped_item(ItemEnums.ItemTypes.ABILITY, 0)
	var ability_1 = Inventory.get_equipped_item(ItemEnums.ItemTypes.ABILITY, 1)

	var item_index := Inventory.inventory_data.items_sorted_flattened.find(item)
	var is_in_ui := item_index >= 0 and item_index * 2 + 1 < get_child_count()
	
	if is_in_ui:
		var item_slot := get_child(item_index * 2) as UiItemSlot
		var controller_slot := get_child(item_index * 2 + 1) as Control
		
		if controller_slot:
			controller_slot.visible = true
			# We'll set show_hold_label after determining the action

		var action = ""
		if item_slot and item_slot.active and (item in melee_items or item in ranged_items):
			action = "attack"
		elif item_slot and !item_slot.active and (item in melee_items or item in ranged_items):
			action = "switch_weapon"
		elif item in melee_items or item in ranged_items:
			action = "attack"
		elif item == ability_0:
			action = "ability_one"
		elif item == ability_1:
			action = "ability_two"
		else:
			action = "switch_weapon"
			
		# Only show hold label for ranged weapons when action is attack
		if controller_slot:
			controller_slot.show_hold_label = (action == "attack" and item in ranged_items)
		
		return action

	return "switch_weapon"

func _should_show_hold_label(item: BaseResource) -> bool:
	if item == null:
		return false
	# Only show for ranged weapons when the current action is attack
	var ranged_items = Inventory.get_equipped_items(ItemEnums.ItemTypes.RANGED_WEAPON)
	return item in ranged_items and _get_input_action_for_item(item) == "attack"

func _init_item_slots(items: Array) -> void:
	for i in range(items.size()):
		var item = items[i]
		if not item is BaseResource:
			continue
		
		# create slots
		var item_slot := ITEM_SLOT.instantiate() as UiItemSlot
		var controller_slot := ITEM_CONTROLLER_ICON_SLOT.instantiate() as Control
		if !item_slot or !controller_slot:
			continue
			
		add_child(item_slot)
		add_child(controller_slot)
		item_slot.item = item

		controller_slot.input_action = _get_input_action_for_item(item)
		controller_slot.show_hold_label = _should_show_hold_label(item)
