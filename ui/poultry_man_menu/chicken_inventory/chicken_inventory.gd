extends Control


@onready var melee_slot: EquipedItemSlot = %MeleeSlot
@onready var ranged_slot: EquipedItemSlot = %RangedSlot
@onready var ability_slot_1: EquipedItemSlot = %AbilitySlot1
@onready var ability_slot_2: EquipedItemSlot = %AbilitySlot2

func _ready() -> void:
	_update_equipped_slots()

func _update_equipped_slots() -> void:
	# Get equipped items from the Inventory autoload
	var melee_weapon: BaseResource = Inventory.get_equipped_item(
		ItemEnums.ItemTypes.MELEE_WEAPON, 0
	)
	var ranged_weapon: BaseResource = Inventory.get_equipped_item(
		ItemEnums.ItemTypes.RANGED_WEAPON, 0
	)
	var ability_1: BaseResource = Inventory.get_equipped_item(
		ItemEnums.ItemTypes.ABILITY, 0
	)
	var ability_2: BaseResource = Inventory.get_equipped_item(
		ItemEnums.ItemTypes.ABILITY, 1
	)

	# Update the UI slots
	if melee_slot:
		melee_slot.display_item(melee_weapon)
	else: push_warning("MeleeSlot node method not found.")

	if ranged_slot:
		ranged_slot.display_item(ranged_weapon)
	else: push_warning("RangedSlot node method not found.")

	if ability_slot_1:
		ability_slot_1.display_item(ability_1)
	else: push_warning("AbilitySlot1 node method not found.")

	if ability_slot_2:
		ability_slot_2.display_item(ability_2)
	else: push_warning("AbilitySlot2 node method not found.")


func _on_visibility_changed() -> void:
	if visible:
		_update_equipped_slots()


func _on_exit_button_pressed():
	UIManager.toggle_ui(UIEnums.UI.CHICKEN_INVENTORY)
