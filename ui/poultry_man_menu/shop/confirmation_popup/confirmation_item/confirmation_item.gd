class_name ConfirmationItem extends BaseShopItem

var shop_item: BaseResource
var show_replace : bool

@onready var type_label: Label = %TypeLabel
@onready var replace_button : Button = %ReplaceButton
@onready var name_label: Label = %NameLabel
@onready var item_icon: TextureRect = %ItemIcon
@onready var description_label: Label = %DescriptionLabel
@onready var cost_label: Label = %CostLabel

func setup(_shop_item : BaseResource, _show_replace):
	set_item_data(_shop_item)
	show_replace = _show_replace

	
func _ready() -> void:
	replace_button.visible = show_replace
	super()


func _on_replace_button_button_up() -> void:
	pass # Replace with function body.

func _replace_item(old_item: Resource, _new_item: Resource) -> void:
	Inventory.remove_item(old_item)
	Inventory.add_item(_new_item)
	GameManager.update_prosperity_eggs(-_new_item.cost)

	print("Item ", old_item, " replaced with ", _new_item)
	queue_free()


func set_item_data(item: Resource) -> void:
	if not (item is BaseResource or item is InRunUpgradeResource):
		if item == null:
			push_error("Item is null")
		push_error("Item is not of appropriate type (BaseResource/InRunUpgradeResource), but instead: ", item.get_class())
		return
		
	shop_item = item
	print(shop_item)
	
func populate_visual_fields() -> void:
	name_label.text = shop_item.name
	if shop_item.icon: item_icon.texture = shop_item.icon
	type_label.text = ItemEnums.item_type_to_string(shop_item.type)
	cost_label.text = str(shop_item.cost)
	description_label.text = shop_item.description
