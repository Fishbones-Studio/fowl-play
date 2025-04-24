class_name ChickenEquipmentContainer
extends VBoxContainer

@export var equipments: Array[ItemEnums.ItemTypes] = []

var _equipment_panel: Array[ChickenEquipmentPanel]
var _ability_slot: int = 0

@onready var equipment_panel_resource: Resource = preload("uid://cuvibbm5bfoje")
@onready var chicken_equipment_panel_container: HBoxContainer = %ChickenEquipmentPanelContainer
@onready var equipment_description: RichTextLabel = %RichTextLabel


func _ready() -> void:
	for equipment_type: ItemEnums.ItemTypes in equipments:
		var equipment_button: ChickenEquipmentPanel = equipment_panel_resource.instantiate()

		_equipment_panel.append(equipment_button)
		chicken_equipment_panel_container.add_child(equipment_button)
		equipment_button.focus_entered.connect(_on_equipment_button_focus_entered.bind(equipment_button))

		_set_equipment_button(equipment_type, equipment_button)

	_on_equipment_button_focus_entered(_equipment_panel[0])


func _on_equipment_button_focus_entered(equipment_button: ChickenEquipmentPanel) -> void:
	# Toggle buttons
	for button: ChickenEquipmentPanel in _equipment_panel:
		button.active = button == equipment_button

	if equipment_button.equipped_item:
		equipment_description.text = equipment_button.equipped_item.description
	else:
		equipment_description.text = "Not equipped."


func _set_equipment_button(item: ItemEnums.ItemTypes, panel: ChickenEquipmentPanel) -> void:
	panel.label.text = "Slot " + str(equipments.find(item) + 1) + " - "

	match item:
		ItemEnums.ItemTypes.MELEE_WEAPON:
			panel.equipped_item = Inventory.get_equipped_item(
				ItemEnums.ItemTypes.MELEE_WEAPON, 0
			)
		ItemEnums.ItemTypes.RANGED_WEAPON:
			panel.equipped_item = Inventory.get_equipped_item(
				ItemEnums.ItemTypes.RANGED_WEAPON, 0
			)
		ItemEnums.ItemTypes.ABILITY:
			panel.equipped_item = Inventory.get_equipped_item(
				ItemEnums.ItemTypes.ABILITY, _ability_slot
			)
			_ability_slot += 1
			panel.label.text = "Slot " + str(_ability_slot) + " - "
		ItemEnums.ItemTypes.HELMET:
			pass
		ItemEnums.ItemTypes.BOOTS:
			pass
		ItemEnums.ItemTypes.UPGRADE:
			pass

	if panel and panel.equipped_item:
		panel.label.text = panel.equipped_item.name
		panel.img.texture = panel.equipped_item.icon
	else:
		panel.label.text += ItemEnums.item_type_to_string(item)
