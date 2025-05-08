extends HBoxContainer

const ITEM_SLOT: PackedScene = preload("uid://ckypq3131wkcv")


func _ready() -> void:
	SignalManager.activate_item_slot.connect(
		func(item: BaseResource ):
			var index : int = Inventory.inventory_data.items_sorted_flattened.find(item)
			
			print("Activating item slot at index: ", index)
			# Check if the item slot is valid
			if index < 0 or index >= get_child_count():
				push_warning("Invalid item slot index: ", index)
				return
			# Activate the item slot
			var item_slot: UiItemSlot = get_child(index) as UiItemSlot
			if item_slot:
				item_slot.active = true
				print("Activated item slot: ", item_slot)
			else:
				# Added closing parenthesis for push_warning
				push_warning("No item slot found at index: ", index)
	)

	SignalManager.deactivate_item_slot.connect(
		func(item: BaseResource ):
			var index : int = Inventory.inventory_data.items_sorted_flattened.find(item)
			print("Deactivating item slot at index: ", index)
			# Check if the item slot is valid
			if index < 0 or index >= get_child_count():
				return
			# Deactivate the item slot
			var item_slot: UiItemSlot = get_child(index) as UiItemSlot
			if item_slot:
				item_slot.active = false
				print("Deactivated item slot: ", item_slot)
			else:
				# Added closing parenthesis for push_warning
				push_warning("No item slot found at index: ", index)
	)

	SignalManager.cooldown_item_slot.connect(
		func(item: BaseResource, cd: float, create_tween : bool):
			var index: int = Inventory.inventory_data.items_sorted_flattened.find(item)
			if index < 0 or index >= get_child_count():
				return
			var item_slot: UiItemSlot = get_child(index) as UiItemSlot
			if item_slot:
				item_slot.start_cooldown(cd, create_tween)
	)

	_init_item_slots(Inventory.inventory_data.items_sorted_flattened)


func _init_item_slots(items: Array) -> void:
	print("Initializing item slots with items: ", items)
	# Clear the container
	for child in get_children():
		child.queue_free()

	# Create item slots
	for i in range(items.size()):
		var item = items[i]
		if not item is BaseResource:
			if item != null: # Only warn if it's not null but wrong type
				push_warning("Item at index ", i, " is not a BaseResource.")
			continue # Skip null or wrong type items

		var item_slot: UiItemSlot = ITEM_SLOT.instantiate() as UiItemSlot
		if item_slot:
			add_child(item_slot)
			item_slot.item = item
		else:
			push_error("Failed to instantiate or cast ITEM_SLOT scene.")
			continue # Skip if instantiation fails
