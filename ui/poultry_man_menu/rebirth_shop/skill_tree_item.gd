extends VBoxContainer

@export var upgrade_type: String = "Damage"
@export var max_level: int = 5
@export var cost_per_level: int = 100
@onready var kind_indicator_label: Label = $Kind_Indicator_Label
@onready var buy_button: Button = $HBoxContainer/Buy_Button
@onready var level_panels: Array = [
	$HBoxContainer/Level1,
	$HBoxContainer/Level2,
	$HBoxContainer/Level3,
	$HBoxContainer/Level4,
	$HBoxContainer/Level5
]

# TODO: uid instead of string
@export var upgrade_resources: Array = [
	preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level1.tres"),
	preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level2.tres"),
	preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level3.tres"),
	preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level4.tres"),
	preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level5.tres")
]

var current_level: int = 0
var copied_stats: LivingEntityStats

func _ready() -> void:
	kind_indicator_label.text = upgrade_type
	# Load current level from saved upgrades dictionary
	var upgrades = SaveManager.get_loaded_player_upgrades()
	current_level = upgrades.get(upgrade_type, 0) 
	copied_stats = SaveManager.get_loaded_player_stats()

	update_panels()

func _on_buy_button_pressed() -> void:
	if current_level < max_level and can_afford_upgrade():
		purchase_upgrade()
		current_level += 1
		update_panels()
		apply_upgrade()
		save_upgrades()
		print("Damage: ",  copied_stats.attack)
		print("Max Health: ", copied_stats.max_health)
		print("Stamina: ", copied_stats.max_stamina)
		print("Speed: " , copied_stats.speed)
		print("Weight: ", copied_stats.weight)
		print("Defense: ", copied_stats.defense)
	else:
		print("Cannot purchase upgrade. Either max level reached or not enough currency.")

func can_afford_upgrade() -> bool:
	return GameManager.feathers_of_rebirth >= cost_per_level

func purchase_upgrade() -> void:
	GameManager.feathers_of_rebirth -= cost_per_level

func apply_upgrade() -> void:
	if current_level <= upgrade_resources.size():
		var upgrade_resource = upgrade_resources[current_level - 1]
		if upgrade_resource == null:
			push_error("Upgrade resource is null!")
			return
		if not upgrade_resource is PermUpgradeResource:
			push_error("Upgrade resource is not a PermUpgradeResource!")
			return
		match upgrade_type:
			"Health":
				copied_stats.max_health += upgrade_resource.health_bonus
			"Stamina":
				copied_stats.max_stamina += upgrade_resource.stamina_bonus
			"Damage":
				copied_stats.attack += upgrade_resource.attack
			"Defense":
				copied_stats.defense += upgrade_resource.defense_bonus
			"Speed":
				copied_stats.speed += upgrade_resource.speed_bonus
			"Weight":
				copied_stats.weight += upgrade_resource.weight_bonus
func update_panels() -> void:
	for i in range(level_panels.size()):
		level_panels[i].visible = i < current_level

func save_upgrades() -> void:
	# Get the current upgrades dictionary
	var upgrades = SaveManager.get_loaded_player_upgrades()
	upgrades[upgrade_type] = current_level
	# Save the game with the updated upgrades
	SaveManager.save_game(copied_stats, upgrades)
	print("Saving Stats: ", copied_stats.to_dict())
	print("Saving Upgrades: ", upgrades)
