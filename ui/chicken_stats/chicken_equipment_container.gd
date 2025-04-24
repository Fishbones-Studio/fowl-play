class_name ChickenEquipmentContainer
extends VBoxContainer

@export var equipments: Array[ItemEnums.ItemTypes] = []

var _equipment_buttons: Array[ChickenEquipmentButton]
var _ability_slot: int = 0

@onready var equipment_button_resource: Resource = preload("uid://cuvibbm5bfoje")
@onready var chicken_equipment_buttons_container: HBoxContainer = %ChickenEquipmentButtonsContainer
@onready var equipment_description: RichTextLabel = %RichTextLabel


func _ready() -> void:
	for equipment_type: ItemEnums.ItemTypes in equipments:
		var equipment_button: ChickenEquipmentButton = equipment_button_resource.instantiate()
		_set_equipment_button(equipment_type, equipment_button)

		_equipment_buttons.append(equipment_button)
		equipment_button.focus_entered.connect(_on_equipment_button_focus_entered.bind(equipment_button))
		chicken_equipment_buttons_container.add_child(equipment_button)

	_on_equipment_button_focus_entered(_equipment_buttons[0])


func _on_equipment_button_focus_entered(equipment_button: ChickenEquipmentButton) -> void:
	# Toggle buttons
	for button: ChickenEquipmentButton in _equipment_buttons:
		button.active = button == equipment_button

	if equipment_button.equipped_item:
		equipment_description.text = equipment_button.equipped_item.description
	else:
		equipment_description.text = "Not equipped."


func _set_equipment_button(item: ItemEnums.ItemTypes, button: ChickenEquipmentButton) -> void:
	button.text = "Slot " + str(equipments.find(item) + 1) + " - "

	match item:
		ItemEnums.ItemTypes.MELEE_WEAPON:
			button.equipped_item = Inventory.get_equipped_item(
				ItemEnums.ItemTypes.MELEE_WEAPON, 0
			)
		ItemEnums.ItemTypes.RANGED_WEAPON:
			button.equipped_item = Inventory.get_equipped_item(
				ItemEnums.ItemTypes.RANGED_WEAPON, 0
			)
		ItemEnums.ItemTypes.ABILITY:
			button.equipped_item = Inventory.get_equipped_item(
				ItemEnums.ItemTypes.ABILITY, _ability_slot
			)
			_ability_slot += 1
			button.text = "Slot " + str(_ability_slot) + " - "
		ItemEnums.ItemTypes.HELMET:
			pass
		ItemEnums.ItemTypes.BOOTS:
			pass
		ItemEnums.ItemTypes.UPGRADE:
			pass

	if button and button.equipped_item:
		button.text = button.equipped_item.name
	else:
		button.text += ItemEnums.item_type_to_string(item)
