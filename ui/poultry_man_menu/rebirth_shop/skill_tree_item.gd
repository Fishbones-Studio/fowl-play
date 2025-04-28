extends VBoxContainer

@export var upgrade_type: String = "Damage"
@export var max_level: int = 5
@export var cost_per_level: int = 100

var current_level: int = 0

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

func _ready() -> void:
	#Load current level from saved data
	current_level = SaveManager.load_upgrade(upgrade_type)
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
		match upgrade_type:
			"Health":
				GameManager.chicken_player.stats.max_health += upgrade_resources[current_level -1].value
				GameManager.chicken_player.stats.current_health += upgrade_resources[current_level -1].value
			"Stamina":
				GameManager.chicken_player.stats.max_stamina += upgrade_resources[current_level -1].value
				GameManager.chicken_player.stats.current_stamina += upgrade_resources[current_level -1].value
			"Attack_Multiplier":
				GameManager.chicken_player.stats.attack_multiplier += upgrade_resources[current_level-1].value
			"Defence":
				GameManager.chicken_player.stats.defense += upgrade_resources[current_level-1].value
			"Speed":
				GameManager.chicken_player.stats.speed += upgrade_resources[current_level - 1].value
			"Weight":
				GameManager.chicken_player.stats.weight += upgrade_resources[current_level -1].value
				
func update_panels() -> void:
	for i in range(level_panels.size()):
		level_panels[i].visible = i < current_level
		
func save_upgrades() -> void:
	SaveManager.save_upgrade(upgrade_type, current_level)
			
