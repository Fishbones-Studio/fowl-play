class_name SkillTreeItem
extends VBoxContainer

@export var upgrade_type: StatsEnums.UpgradeTypes

var copied_stats: LivingEntityStats
var upgrade_resource: PermUpgradesResource
var prosperity_egg_icon: CompressedTexture2D = preload("uid://be0yl1q0uryjp")
var feathers_of_rebirth_icon: CompressedTexture2D = preload("uid://brgdaqksfgmqu")

@onready var kind_indicator_label: Label = %KindIndicatorLabel
@onready var buy_button: Button = %BuyButton
@onready var level_progress_bar: ProgressBar = %LevelProgressBar
@onready var level_label: Label = %LevelLabel
@onready var item_currency_icon: TextureRect = %ItemCurrencyIcon
@onready var item_cost_label: Label = %ItemCostLabel


func _ready() -> void:
	if not copied_stats:
		copied_stats = SaveManager.get_loaded_player_stats()


func init(
	_upgrade_type: StatsEnums.UpgradeTypes,
	_upgrade: PermUpgradesResource,
	_copied_stats: LivingEntityStats
) -> void:
	print(_upgrade)
	upgrade_type = _upgrade_type
	upgrade_resource = _upgrade
	upgrade_resource.current_level = SaveManager.get_loaded_player_upgrades().get(upgrade_type, 0)
	copied_stats = _copied_stats
	kind_indicator_label.text = StatsEnums.upgrade_type_to_string(_upgrade_type)
	update_ui_elements()


func _on_buy_button_pressed() -> void:
	if not upgrade_resource:
		return
	if upgrade_resource.current_level < upgrade_resource.max_level and can_afford_upgrade():
		purchase_upgrade()
		update_ui_elements()
		apply_upgrade()
		save_upgrades()
	else:
		print("Cannot purchase upgrade. Either max level reached or not enough currency.")


func can_afford_upgrade() -> bool:
	if upgrade_resource.current_level >= upgrade_resource.max_level:
		return false
	match upgrade_resource.currency_type:
		CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
			return GameManager.feathers_of_rebirth >= upgrade_resource.get_level_cost(upgrade_resource.current_level+1)
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
			return GameManager.prosperity_eggs >= upgrade_resource.get_level_cost(upgrade_resource.current_level+1)
		_:
			return false


func purchase_upgrade() -> void:
	match upgrade_resource.currency_type:
		CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
			GameManager.feathers_of_rebirth -= upgrade_resource.get_level_cost(upgrade_resource.current_level+1)
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
			GameManager.prosperity_eggs -= upgrade_resource.get_level_cost(upgrade_resource.current_level+1)
	upgrade_resource.current_level += 1


func apply_upgrade() -> void:
	if upgrade_resource.current_level == 0 or upgrade_resource.current_level > upgrade_resource.max_level:
		return
	if upgrade_resource == null:
		push_error("Upgrade resource is null!")
		return
	if not upgrade_resource is PermUpgradesResource:
		push_error("Upgrade resource is not a PermUpgradeResource!")
		return
	match upgrade_type:
		StatsEnums.UpgradeTypes.MAX_HEALTH:
			copied_stats.max_health += upgrade_resource.get_upgrade_resource().health_bonus
		StatsEnums.UpgradeTypes.STAMINA:
			copied_stats.max_stamina += upgrade_resource.get_upgrade_resource().stamina_bonus
		StatsEnums.UpgradeTypes.DAMAGE:
			copied_stats.attack += upgrade_resource.get_upgrade_resource().attack_bonus
		StatsEnums.UpgradeTypes.DEFENSE:
			copied_stats.defense += upgrade_resource.get_upgrade_resource().defense_bonus
		StatsEnums.UpgradeTypes.SPEED:
			copied_stats.speed += upgrade_resource.get_upgrade_resource().speed_bonus
		StatsEnums.UpgradeTypes.WEIGHT:
			copied_stats.weight += upgrade_resource.get_upgrade_resource().weight_bonus


func update_ui_elements() -> void:
	level_progress_bar.max_value = upgrade_resource.max_level
	level_progress_bar.value = upgrade_resource.current_level
	buy_button.disabled = upgrade_resource.current_level >= upgrade_resource.max_level

	if upgrade_resource.current_level < upgrade_resource.max_level:
		item_cost_label.text = str(upgrade_resource.get_level_cost(upgrade_resource.current_level + 1))
		match upgrade_resource.currency_type:
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

	if upgrade_resource.current_level < upgrade_resource.max_level:
		level_label.text = str(upgrade_resource.current_level)
	else:
		level_label.text = "MAX"


func save_upgrades() -> void:
	var upgrades : Dictionary[StatsEnums.UpgradeTypes, int] = SaveManager.get_loaded_player_upgrades()
	upgrades[upgrade_type] = upgrade_resource.current_level
	SaveManager.save_player_upgrades(upgrades)
