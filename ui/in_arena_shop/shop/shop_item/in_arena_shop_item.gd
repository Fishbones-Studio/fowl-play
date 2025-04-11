class_name InArenaShopItem
extends BaseShopItem

var upgrade_item: InRunUpgradeResource

@onready var bonus_label: Label = %BonusLabel
@onready var name_label: Label = %NameLabel
@onready var item_icon: TextureRect = %ItemIcon
@onready var description_label: Label = %DescriptionLabel
@onready var cost_label: Label = %CostLabel


func set_item_data(item: Resource) -> void:
	if !item is InRunUpgradeResource:
		if item == null:
			push_error("Item is null")
			return
		push_error("Item is not of type InRunUpgradeResource")
		return
		
	upgrade_item = item as InRunUpgradeResource

	
func populate_visual_fields() -> void:
	name_label.text = upgrade_item.name
	if upgrade_item.icon: item_icon.texture = upgrade_item.icon
	bonus_label.text = upgrade_item.get_bonus_string()
	cost_label.text = str(upgrade_item.cost)
	description_label.text = upgrade_item.description



func attempt_purchase() -> void:
	if purchase_in_progress or not can_afford():
		return

	purchase_in_progress = true

	if upgrade_item.health_bonus > 0:
		GameManager.chicken_player.stats.max_health += upgrade_item.health_bonus
		GameManager.chicken_player.stats.current_health += upgrade_item.health_bonus

	if upgrade_item.stamina_bonus > 0:
		GameManager.chicken_player.stats.max_stamina += upgrade_item.stamina_bonus
		GameManager.chicken_player.stats.current_stamina += upgrade_item.stamina_bonus

	GameManager.prosperity_eggs -= int(cost_label.text)
	self.visible = false
	purchase_in_progress = false

	
func can_afford() -> bool:
	return GameManager.prosperity_eggs >= upgrade_item.cost
