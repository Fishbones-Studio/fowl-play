class_name InArenaShopItem
extends BaseShopItem

var upgrade_item: InRunUpgradeResource

@onready var bonus_label: Label = %BonusLabel


func _ready() -> void:
	# setting up the labels
	name_label = %NameLabel
	item_icon = %ItemIcon
	description_label = %DescriptionLabel
	cost_label = %CostLabel


func set_item_data(item: Resource) -> void:
	if !item is InRunUpgradeResource:
		push_error("Item is not of type InRunUpgradeResource")
		return

	name_label.text = item.name
	bonus_label.text = item.get_bonus_string()
	cost_label.text = str(item.cost)
	description_label.text = item.description
	upgrade_item = item


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
