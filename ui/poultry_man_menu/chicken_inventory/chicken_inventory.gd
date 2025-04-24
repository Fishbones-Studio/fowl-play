extends Control

var ability_1 : AbilityResource = null
var ability_2 : AbilityResource = null

@onready var equipment_grid : GridContainer = %EquipmentGrid
@onready var melee_slot: EquipedItemSlot = %MeleeSlot
@onready var ranged_slot: EquipedItemSlot = %RangedSlot
@onready var ability_slot_1: EquipedItemSlot = %AbilitySlot1
@onready var ability_slot_2: EquipedItemSlot = %AbilitySlot2
@onready var close_button: Button = %CloseButton
@onready var item_preview_container : ItemPreviewContainer = %ItemPreviewContainer


func _ready() -> void:
	_setup_controller_navigation()
	_update_equipped_slots()
	
	SignalManager.preview_shop_item.connect(_on_populate_visual_fields)


func _setup_controller_navigation() -> void:
	# Make equipped slots and close button focusable
	if melee_slot:
		melee_slot.focus_mode = Control.FOCUS_ALL
	if ranged_slot:
		ranged_slot.focus_mode = Control.FOCUS_ALL
	if ability_slot_1:
		ability_slot_1.focus_mode = Control.FOCUS_ALL
	if ability_slot_2:
		ability_slot_2.focus_mode = Control.FOCUS_ALL


func _update_equipped_slots() -> void:
	# Get equipped items from the Inventory autoload
	var melee_weapon: BaseResource = Inventory.get_equipped_item(
		ItemEnums.ItemTypes.MELEE_WEAPON, 0
	)
	var ranged_weapon: BaseResource = Inventory.get_equipped_item(
		ItemEnums.ItemTypes.RANGED_WEAPON, 0
	)
	ability_1 = Inventory.get_equipped_item(
		ItemEnums.ItemTypes.ABILITY, 0
	) as AbilityResource
	ability_2= Inventory.get_equipped_item(
		ItemEnums.ItemTypes.ABILITY, 1
	) as AbilityResource

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
	
func _on_populate_visual_fields(item: BaseResource) -> void:
	item_preview_container.visible = item != null
	if item == null:
		return

	item_preview_container.setup(item)


func _on_visibility_changed() -> void:
	if visible:
		_update_equipped_slots()
		# Set initial focus when the inventory appears
		await get_tree().process_frame # Wait a frame for UI to update
		if melee_slot and melee_slot.focus_mode != Control.FOCUS_NONE:
			print("grabbing focus on melee slot")
			melee_slot.grab_focus()
		elif close_button and close_button.focus_mode != Control.FOCUS_NONE:
			# Fallback to close button if melee slot isn't available/focusable
			close_button.grab_focus()


func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.CHICKEN_INVENTORY)


func _on_swap_abilities_button_pressed() -> void:
	# swapp the abilities in slot one and two
	Inventory.inventory_data.ability_slot_one = ability_2
	Inventory.inventory_data.ability_slot_two = ability_1
	Inventory.save_inventory()
	_update_equipped_slots()
