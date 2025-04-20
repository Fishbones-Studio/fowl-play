extends AbilitySlot


func _ready() -> void:
	if not ability_resource:
		ability_resource = Inventory.inventory_data.ability_slot_two
