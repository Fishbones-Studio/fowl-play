class_name InArenaShopItem
extends BaseShopItem

var upgrade_item: InRunUpgradeResource

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

	upgrade_item = item as InRunUpgradeResource
	print(upgrade_item)


func populate_visual_fields() -> void:
	name_label.text = upgrade_item.name
	if upgrade_item.icon: item_icon.texture = upgrade_item.icon
	bonus_label.text = upgrade_item.get_bonus_string()
	cost_label.text = "PE: %d" % upgrade_item.pe_cost
	description_label.text = upgrade_item.description


func attempt_purchase() -> void:
	if purchase_in_progress or not can_afford():
		return

	purchase_in_progress = true

	GameManager.chicken_player.stats.apply_upgrade(upgrade_item)

	GameManager.prosperity_eggs -= int(upgrade_item.pe_cost)
	self.visible = false
	super()


func can_afford() -> bool:
	return GameManager.prosperity_eggs >= upgrade_item.pe_cost
