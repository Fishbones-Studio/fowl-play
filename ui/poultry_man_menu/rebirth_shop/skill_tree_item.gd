class_name SkillTreeItem
extends VBoxContainer

@export var upgrade_type: StatsEnums.UpgradeTypes
@export var max_level: int = 5
@onready var kind_indicator_label: Label = $KindIndicatorLabel
@onready var buy_button: Button = $HBoxContainer/Buy_Button
@onready var level_panels: Array = [
	$HBoxContainer/Level1,
	$HBoxContainer/Level2,
	$HBoxContainer/Level3,
	$HBoxContainer/Level4,
	$HBoxContainer/Level5
]

signal shop_refresh_needed

var current_level: int = 0
var copied_stats: LivingEntityStats
var purchased_color: Color = Color(0, 1, 0)
var unpurchased_color: Color = Color(0.5, 0.5, 0.5)
var upgrade_resources: Array[PermUpgradeResource] = []

func _ready() -> void:
	kind_indicator_label.text = StatsEnums.upgrade_type_to_string(upgrade_type)
	var upgrades = SaveManager.get_loaded_player_upgrades()
	current_level = upgrades.get(upgrade_type, 0)
	if not copied_stats:
		copied_stats = SaveManager.get_loaded_player_stats()
	update_panels()

func init(_upgrade_type: StatsEnums.UpgradeTypes, _upgrades: Array[PermUpgradeResource], _copied_stats: LivingEntityStats) -> void:
	upgrade_type = _upgrade_type
	upgrade_resources = _upgrades
	copied_stats = _copied_stats
	kind_indicator_label.text = StatsEnums.upgrade_type_to_string(_upgrade_type)
	var upgrades_dict = SaveManager.get_loaded_player_upgrades()
	current_level = upgrades_dict.get(upgrade_type, 0)
	update_panels()

func _on_buy_button_pressed() -> void:
	if !upgrade_resources : return
	if current_level < max_level and can_afford_upgrade():
		purchase_upgrade()
		current_level += 1
		update_panels()
		apply_upgrade()
		save_upgrades()
		emit_signal("shop_refresh_needed")
		print("Damage: ",  copied_stats.attack)
		print("Max Health: ", copied_stats.max_health)
		print("Stamina: ", copied_stats.max_stamina)
		print("Speed: " , copied_stats.speed)
		print("Weight: ", copied_stats.weight)
		print("Defense: ", copied_stats.defense)
	else:
		print("Cannot purchase upgrade. Either max level reached or not enough currency.")

func can_afford_upgrade() -> bool:
	if current_level >= upgrade_resources.size():
		return false
	var upgrade_resource = upgrade_resources[current_level]
	return GameManager.feathers_of_rebirth >= upgrade_resource.cost

func purchase_upgrade() -> void:
	var upgrade_resource = upgrade_resources[current_level]
	GameManager.feathers_of_rebirth -= upgrade_resource.cost

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

func update_panels() -> void:
	for i in range(level_panels.size()):
		var panel = level_panels[i]
		var color_rect = panel.get_node("ColorRect")
		if i < current_level:
			color_rect.color = purchased_color
		else:
			color_rect.color = unpurchased_color

func save_upgrades() -> void:
	var upgrades = SaveManager.get_loaded_player_upgrades()
	upgrades[upgrade_type] = current_level
	SaveManager.save_game(copied_stats, upgrades)
