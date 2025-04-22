class_name ShopItem
extends BaseShopItem

signal purchased
signal purchase_cancelled

var shop_item: BaseResource

@onready var type_label: Label = %TypeLabel
@onready var name_label : Label = %NameLabel
@onready var item_icon: TextureRect = %ItemIcon
@onready var description_label: Label = %DescriptionLabel
@onready var cost_label: Label = %CostLabel


func _ready() -> void:
	purchased.connect(_on_purchase_complete)
	purchase_cancelled.connect(func(): purchase_in_progress = false)
	super()


func _on_purchase_complete() -> void:
	print("Item bought: ", name_label.text, " │ Type: ", type_label.text)
	GameManager.prosperity_eggs -= shop_item.cost
	Inventory.add_item(shop_item)
	super.attempt_purchase()
	queue_free()


func set_item_data(item: Resource) -> void:
	if not item is BaseResource or item is InRunUpgradeResource:
		if item == null:
			push_error("Item is null")
			return
		push_error("Item is not of appropriate type (BaseResource/InRunUpgradeResource), but instead: ", item.get_class())
		return

	shop_item = item as BaseResource


func populate_visual_fields() -> void:
	name_label.text = shop_item.name
	if shop_item.icon: item_icon.texture = shop_item.icon
	type_label.text = ItemEnums.item_type_to_string(shop_item.type)
	cost_label.text = str(shop_item.cost)
	description_label.text = shop_item.description
	print(shop_item)


func attempt_purchase() -> void:
	# Prevent purchase if one is already in progress or player can't afford it
	if purchase_in_progress or not can_afford():
		return

	purchase_in_progress = true

	var existing_items: Array[BaseResource] = Inventory.get_items_by_type(shop_item.type)
	
	if existing_items.has(shop_item):
		print("Item already owned")
		purchase_in_progress = false
		super()
		return

	# If player already has items of this type, show selection UI to replace
	if existing_items.is_empty() or existing_items.size() < shop_item.type_max_owned_amount:
		#TODO: add a confirmaiton popup
		_on_purchase_complete()
	else:
		# TODO: add the just replaced item back to the shop?
		# TODO: for abilities, somehow show both possible abilites to replace
		SignalManager.add_ui_scene.emit(UIEnums.UI.POULTRYMAN_SHOP_CONFIRMATION, {
			"existing_item": existing_items[0],
			"new_item": shop_item,
			"purchased_signal": purchased,
			"purchase_cancelled": purchase_cancelled
		})


func can_afford() -> bool:
	return GameManager.prosperity_eggs >= shop_item.cost
