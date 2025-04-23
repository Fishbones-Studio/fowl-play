class_name InArenaShopItem
extends BaseShopItem

@onready var bonus_label: Label = %BonusLabel
@onready var name_label: Label = %NameLabel
@onready var item_icon: TextureRect = %ItemIcon
@onready var description_label: Label = %DescriptionLabel
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
	name_label.text = shop_item.name
	if shop_item.icon: item_icon.texture = shop_item.icon
	bonus_label.text = shop_item.get_bonus_string()
	cost_label.text = str(shop_item.cost)
	description_label.text = shop_item.description


func attempt_purchase() -> void:
	if purchase_in_progress or not can_afford():
		return

	purchase_in_progress = true

	GameManager.chicken_player.stats.apply_upgrade(shop_item)

	GameManager.prosperity_eggs -= int(shop_item.cost)
	self.visible = false
	super()


func can_afford() -> bool:
	return GameManager.prosperity_eggs >= shop_item.cost
