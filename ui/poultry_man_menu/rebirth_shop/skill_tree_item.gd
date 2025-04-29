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

@export var upgrade_resources: Array = [
	preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level1.tres"),
	preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level2.tres"),
	preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level3.tres"),
	preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level4.tres"),
	preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level5.tres")
]

var original_stats = ResourceLoader.load("res://entities/chicken_player/player_stats.tres")
var current_level: int = 0
var copied_stats = original_stats.duplicate()

func _ready() -> void:
	print("copied_stats properties:", copied_stats)
	print("upgraded_stats properties:", upgrade_resources)
		
	kind_indicator_label.text = upgrade_type
	#Load current level from saved data
	current_level = SaveManager.load_game(copied_stats).get(upgrade_type, 0)
	#Initialize the panels to the right level
	update_panels()
	

func _on_buy_button_pressed() -> void:
	if current_level < max_level and can_afford_upgrade():
		purchase_upgrade()
		current_level += 1
		update_panels()
		apply_upgrade()
		save_upgrades()
	else:
		print("Cannot purchase upgrade. Either max level reached or not enough currency.")
func can_afford_upgrade() -> bool:
	return GameManager.feathers_of_rebirth >= cost_per_level
	
func purchase_upgrade() -> void:
	GameManager.feathers_of_rebirth -= cost_per_level

func apply_upgrade() -> void:
	if current_level <= upgrade_resources.size():
		print("Current level:", current_level)
		var upgrade_resource = upgrade_resources[current_level -1]
		if upgrade_resource == null:
			push_error("Upgrade resource is null!")
			return
		if not upgrade_resource is PermUpgradeResource:
			push_error("Upgrade resource is not a PermUpgradeResource!")
			return
		match upgrade_type:
			"Health":
				copied_stats.max_health += upgrade_resources[current_level -1].value
			"Stamina":
				copied_stats.max_stamina += upgrade_resources[current_level -1].value
			"Attack_Multiplier":
				copied_stats.attack_multiplier += upgrade_resources[current_level-1].value
				print("After upgrade - copied_stats.attack_multiplier:", copied_stats.attack_multiplier)
			"Defence":
				copied_stats.stats.defense += upgrade_resources[current_level-1].value
			"Speed":
				copied_stats.stats.speed += upgrade_resources[current_level - 1].value
			"Weight":
				copied_stats.stats.weight += upgrade_resources[current_level -1].value
	print("Original stats attack_multiplier:", original_stats.attack_multiplier)
	print("Copied stats attack_multiplier:", copied_stats.attack_multiplier)
func update_panels() -> void:
	for i in range(level_panels.size()):
		level_panels[i].visible = i < current_level
		
func save_upgrades() -> void:
	
	var upgrades = SaveManager.load_game(copied_stats)
	upgrades[upgrade_type] = current_level
	SaveManager.save_game(copied_stats, upgrades)
			
