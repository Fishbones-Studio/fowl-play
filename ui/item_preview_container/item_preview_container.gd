class_name ItemPreviewContainer 
extends VBoxContainer

@onready var shop_preview_label: Label = %ItemPreviewLabel
@onready var shop_preview_icon: TextureRect = %ItemPreviewIcon
@onready var shop_preview_type: Label = %ItemPreviewType
@onready var shop_preview_description: RichTextLabel = %ItemPreviewDescription


func setup(item: BaseResource) -> void:
	shop_preview_label.text = item.name
	if item.icon:
		shop_preview_icon.texture = item.icon
	shop_preview_type.text = ItemEnums.item_type_to_string(item.type)
	shop_preview_description.text = item.description % item.get_modifier_string()
