class_name ChickenEquipmentContainer
extends VBoxContainer

@export var equipments: Array[ItemEnums.ItemTypes] = []
@export var item_preview: ItemPreviewContainer

var _equipment_panels: Array[ChickenEquipmentPanel]
var _ability_slot: int = 0
var _item_focused: bool = false

@onready var equipment_panel_resource: Resource = preload("uid://cuvibbm5bfoje")


func _ready() -> void:
	assert(item_preview, "Item preview not set for: " + self.name)

	for equipment_type: ItemEnums.ItemTypes in equipments:
		var equipment_panel: ChickenEquipmentPanel = equipment_panel_resource.instantiate()

		add_child(equipment_panel)
		_equipment_panels.append(equipment_panel)
		equipment_panel.focus_entered.connect(_on_equipment_panels_focus_entered.bind(equipment_panel))

		_set_equipment_panels(equipment_type, equipment_panel)

	for item: ChickenEquipmentPanel in _equipment_panels:
		if item.equipped_item:
			item.grab_focus()
			_item_focused = true
			break

	if not _item_focused:
		_equipment_panels[0].grab_focus()


func _on_equipment_panels_focus_entered(equipment_panel: ChickenEquipmentPanel) -> void:
	for panel: ChickenEquipmentPanel in _equipment_panels: # Toggle panels
		panel.active = panel == equipment_panel

	if equipment_panel.equipped_item: # Set the preview item
		await get_tree().process_frame

		item_preview.setup(equipment_panel.equipped_item)
		item_preview.visible = true
	else:
		item_preview.visible = false


func _set_equipment_panels(item: ItemEnums.ItemTypes, panel: ChickenEquipmentPanel) -> void:
	panel.label.text = ItemEnums.item_type_to_string(item) + " "

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
			panel.label.text += str(_ability_slot + 1) + " "
			_ability_slot += 1
		ItemEnums.ItemTypes.UPGRADE:
			pass

	if panel and panel.equipped_item:
		panel.label.text = panel.equipped_item.name
		panel.img.texture = panel.equipped_item.icon
	else:
		panel.label.text += "- Empty"
