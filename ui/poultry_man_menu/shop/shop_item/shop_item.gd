class_name ShopItem
extends BaseShopItem

signal purchased
signal purchase_cancelled

const PROSPERITY_EGGS_ICON = preload("uid://be0yl1q0uryjp")
const FEATHERS_OF_REBIRTH_ICON = preload("uid://dbrl2j52kvydc") #TODO, temp

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_label: Label = %ItemLabel
@onready var item_currency_icon: TextureRect = %ItemCurrencyIcon
@onready var item_cost_label: Label = %ItemCostLabel


func _ready() -> void:
	purchased.connect(_on_purchase_complete)
	purchase_cancelled.connect(func(): purchase_in_progress = false)
	super()


func set_item_data(item: Resource) -> void:
	if not item is BaseResource or item is InRunUpgradeResource:
		if item == null:
			push_error("Item is null")
			return
		push_error("Item is not of appropriate type (BaseResource/InRunUpgradeResource), but instead: ", item.get_class())
		return

	shop_item = item as BaseResource


func populate_visual_fields() -> void:
	if shop_item.icon: item_icon.texture = shop_item.icon
	item_label.text = shop_item.name
	item_currency_icon.texture = PROSPERITY_EGGS_ICON if shop_item.currency_type == CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS else FEATHERS_OF_REBIRTH_ICON
	item_cost_label.text = str(shop_item.cost)


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
		#TODO: add a confirmation popup
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


func _on_purchase_complete() -> void:
	GameManager.prosperity_eggs -= shop_item.cost
	Inventory.add_item(shop_item)
	super.attempt_purchase()
	queue_free()
