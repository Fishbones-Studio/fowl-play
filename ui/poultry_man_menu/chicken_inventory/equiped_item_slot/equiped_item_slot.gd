class_name EquipedItemSlot extends PanelContainer

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name: Label = %ItemName

# Optional: Add a default empty texture
@export var empty_slot_texture: Texture2D

func display_item(item: BaseResource) -> void:
	if item:
		item_name.text = item.name
		if item.icon:
			item_icon.texture = item.icon
			item_icon.show()
		else:
			# Handle items without icons if necessary
			item_icon.texture = empty_slot_texture # Or hide
			if empty_slot_texture == null: item_icon.hide()

	else:
		item_name.text = "Empty"
		item_icon.texture = empty_slot_texture # Show empty slot texture
		if empty_slot_texture == null: item_icon.hide()
