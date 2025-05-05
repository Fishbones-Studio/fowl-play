class_name SkillTreeItem
extends VBoxContainer

@export var upgrade_type: StatsEnums.UpgradeTypes
@export var max_level: int = 5

signal shop_refresh_needed

var current_level: int = 0
var copied_stats: LivingEntityStats
var upgrade_resources: Array[PermUpgradeResource] = []
var prosperity_egg_icon: CompressedTexture2D = preload("uid://be0yl1q0uryjp")
var feathers_of_rebirth_icon: CompressedTexture2D = preload("uid://brgdaqksfgmqu")

@onready var kind_indicator_label: Label = %KindIndicatorLabel
@onready var buy_button: Button = %BuyButton
@onready var level_progress_bar: ProgressBar = %LevelProgressBar
@onready var level_label: Label = %LevelLabel
@onready var item_currency_icon: TextureRect = %ItemCurrencyIcon
@onready var item_cost_label: Label = %ItemCostLabel

func _ready() -> void:
	kind_indicator_label.text = StatsEnums.upgrade_type_to_string(upgrade_type)
	var upgrades = SaveManager.get_loaded_player_upgrades()
	current_level = upgrades.get(upgrade_type, 0)
	if not copied_stats:
		copied_stats = SaveManager.get_loaded_player_stats()
	update_ui_elements()

func init(
	_upgrade_type: StatsEnums.UpgradeTypes,
	_upgrades: Array[PermUpgradeResource],
	_copied_stats: LivingEntityStats
) -> void:
	upgrade_type = _upgrade_type
	upgrade_resources = _upgrades
	copied_stats = _copied_stats
	kind_indicator_label.text = StatsEnums.upgrade_type_to_string(_upgrade_type)
	var upgrades_dict = SaveManager.get_loaded_player_upgrades()
	current_level = upgrades_dict.get(upgrade_type, 0)
	update_ui_elements()

func _on_buy_button_pressed() -> void:
	if not upgrade_resources:
		return
	if current_level < max_level and can_afford_upgrade():
		purchase_upgrade()
		current_level += 1
		update_ui_elements()
		apply_upgrade()
		save_upgrades()
		emit_signal("shop_refresh_needed")
		print("Damage: ", copied_stats.attack)
		print("Max Health: ", copied_stats.max_health)
		print("Stamina: ", copied_stats.max_stamina)
		print("Speed: ", copied_stats.speed)
		print("Weight: ", copied_stats.weight)
		print("Defense: ", copied_stats.defense)
	else:
		print("Cannot purchase upgrade. Either max level reached or not enough currency.")

func can_afford_upgrade() -> bool:
	if current_level >= upgrade_resources.size():
		return false
	var upgrade_resource = upgrade_resources[current_level]
	match upgrade_resource.currency_type:
		CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
			return GameManager.feathers_of_rebirth >= upgrade_resource.cost
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
			return GameManager.prosperity_eggs >= upgrade_resource.cost
		_:
			return false

func purchase_upgrade() -> void:
	var upgrade_resource = upgrade_resources[current_level]
	match upgrade_resource.currency_type:
		CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
			GameManager.feathers_of_rebirth -= upgrade_resource.cost
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
			GameManager.prosperity_eggs -= upgrade_resource.cost

func apply_upgrade() -> void:
	if current_level == 0 or current_level > upgrade_resources.size():
		return
	var upgrade_resource = upgrade_resources[current_level - 1]
	if upgrade_resource == null:
		push_error("Upgrade resource is null!")
		return
	if not upgrade_resource is PermUpgradeResource:
		push_error("Upgrade resource is not a PermUpgradeResource!")
		return
	match upgrade_type:
		StatsEnums.UpgradeTypes.HEALTH:
			copied_stats.max_health += upgrade_resource.health_bonus
		StatsEnums.UpgradeTypes.STAMINA:
			copied_stats.max_stamina += upgrade_resource.stamina_bonus
		StatsEnums.UpgradeTypes.DAMAGE:
			copied_stats.attack += upgrade_resource.attack
		StatsEnums.UpgradeTypes.DEFENSE:
			copied_stats.defense += upgrade_resource.defense_bonus
		StatsEnums.UpgradeTypes.SPEED:
			copied_stats.speed += upgrade_resource.speed_bonus
		StatsEnums.UpgradeTypes.WEIGHT:
			copied_stats.weight += upgrade_resource.weight_bonus

func update_ui_elements() -> void:
	level_progress_bar.max_value = max_level
	level_progress_bar.value = current_level
	buy_button.disabled = current_level >= max_level

	if current_level < max_level and current_level < upgrade_resources.size():
		var next_upgrade = upgrade_resources[current_level]
		item_cost_label.text = str(next_upgrade.cost)
		match next_upgrade.currency_type:
			CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
				item_currency_icon.texture = prosperity_egg_icon
			_:
				item_currency_icon.texture = feathers_of_rebirth_icon
		item_cost_label.show()
		item_currency_icon.show()
		buy_button.disabled = false
	else:
		item_cost_label.hide()
		item_currency_icon.hide()
		buy_button.disabled = true

	if current_level < max_level:
		level_label.text = str(current_level)
	else:
		level_label.text = "MAX"

func save_upgrades() -> void:
	var upgrades = SaveManager.get_loaded_player_upgrades()
	upgrades[upgrade_type] = current_level
	SaveManager.save_game(copied_stats, upgrades)
