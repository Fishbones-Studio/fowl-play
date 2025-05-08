extends HBoxContainer

const ITEM_SLOT: PackedScene = preload("uid://ckypq3131wkcv")
const ITEM_CONTROLLER_ICON_SLOT: PackedScene = preload("uid://yq62iccynmnp")

func _ready() -> void:
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
				controller_slot.visible = false
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


func _init_item_slots(items: Array) -> void:
	print("Initializing item slots with items: ", items)
	# Clear the container
	for child in get_children():
		child.queue_free()

	# Create item slots and corresponding controller icons
	for i in range(items.size()):
		var item = items[i]
		if not item is BaseResource:
			if item != null: # Only warn if it's not null but wrong type
				push_warning("Item at index ", i, " is not a BaseResource.")
			continue # Skip null or wrong type items

		# Create regular item slot
		var item_slot: UiItemSlot = ITEM_SLOT.instantiate() as UiItemSlot
		if item_slot:
			add_child(item_slot)
			item_slot.item = item
		else:
			push_error("Failed to instantiate or cast ITEM_SLOT scene.")
			continue # Skip if instantiation fails

		# Create controller icon slot
		var controller_slot: Control = ITEM_CONTROLLER_ICON_SLOT.instantiate() as Control
		if controller_slot:
			add_child(controller_slot)
			
			# Set the input action based on slot position
			match i:
				2:  # 3rd slot (index 2)
					controller_slot.input_action = "ability_one"
				3:  # 4th slot (index 3)
					controller_slot.input_action = "ability_two"
				_:  # Other slots
					controller_slot.input_action = ""  # or set a default action
		else:
			push_error("Failed to instantiate or cast ITEM_CONTROLLER_ICON_SLOT scene.")
			# Remove the item slot we just added if controller slot failed
			item_slot.queue_free()
			continue
