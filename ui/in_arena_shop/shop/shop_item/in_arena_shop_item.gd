class_name InArenaShopItem
extends BaseShopItem

@onready var item_icon: TextureRect = %ItemIcon
@onready var name_label: Label = %NameLabel
@onready var currency_icon: TextureRect = %CurrencyIcon
@onready var cost_label: Label = %CostLabel


func _ready() -> void:
	super()


func set_item_data(item: Resource) -> void:
	if not item is InRunUpgradeResource:
		if item == null:
			push_error("Item is null")
			return
		push_error("Item is not of type InRunUpgradeResource")
		return

	shop_item = item as InRunUpgradeResource


func populate_visual_fields() -> void:
	if shop_item.icon: item_icon.texture = shop_item.icon
	name_label.text = shop_item.name
	currency_icon.texture = prosperity_egg_icon if shop_item.currency_type == CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS else feathers_of_rebirth_icon
	cost_label.text = str(shop_item.cost)


func attempt_purchase() -> void:
	if purchase_in_progress or not can_afford():
		return

	purchase_in_progress = true

	GameManager.chicken_player.stats.apply_upgrade(shop_item)

	if shop_item.currency_type == CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
		GameManager.prosperity_eggs -= shop_item.cost
	elif shop_item.currency_type == CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
		GameManager.feathers_of_rebirth -= shop_item.cost

	self.visible = false
	super()
