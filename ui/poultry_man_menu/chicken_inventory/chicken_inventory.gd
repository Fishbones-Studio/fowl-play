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
@onready var swap_abilities_button : Button = %SwapAbilitiesButton
@onready var invisible_area : Control = %InvisibleArea


func _ready() -> void:
	_setup_controller_navigation()
	_update_equipped_slots()
	
	SignalManager.preview_shop_item.connect(_on_populate_visual_fields)


func _setup_controller_navigation() -> void:
	if melee_slot:
		melee_slot.focus_mode = Control.FOCUS_ALL
	if ranged_slot:
		ranged_slot.focus_mode = Control.FOCUS_ALL
	if ability_slot_1:
		ability_slot_1.focus_mode = Control.FOCUS_ALL
	if ability_slot_2:
		ability_slot_2.focus_mode = Control.FOCUS_ALL
	if close_button:
		close_button.focus_mode = Control.FOCUS_ALL
	if swap_abilities_button:
		swap_abilities_button.focus_mode = Control.FOCUS_ALL

	if melee_slot and ranged_slot and ability_slot_1 and ability_slot_2	and close_button and swap_abilities_button:
		melee_slot.focus_neighbor_right  = ranged_slot.get_path()
		melee_slot.focus_neighbor_bottom = ability_slot_1.get_path()

		ranged_slot.focus_neighbor_left   = melee_slot.get_path()
		ranged_slot.focus_neighbor_bottom = ability_slot_2.get_path()

		ability_slot_1.focus_neighbor_top    = melee_slot.get_path()
		ability_slot_1.focus_neighbor_bottom = ability_slot_2.get_path()

		ability_slot_2.focus_neighbor_top    = ability_slot_1.get_path()
		ability_slot_2.focus_neighbor_bottom = swap_abilities_button.get_path()

		swap_abilities_button.focus_neighbor_top   = ability_slot_2.get_path()
		swap_abilities_button.focus_neighbor_right = close_button.get_path()

		close_button.focus_neighbor_left = swap_abilities_button.get_path()



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
	invisible_area.visible = !item_preview_container.visible 
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
