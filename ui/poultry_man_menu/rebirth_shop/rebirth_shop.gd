extends Control

const SKILL_TREE_ITEM = preload("uid://cdudy6ia0qr8w")
@onready var items: VBoxContainer = $Panel/VBoxContainer/MarginContainer/Items
@onready var h_separator: HSeparator = $Panel/VBoxContainer/MarginContainer/Items/HSeparator



func _ready() -> void:
	_refresh_shop()

func _input(_event: InputEvent) -> void:
	if (Input.is_action_just_pressed("pause") \
	or Input.is_action_just_pressed("ui_cancel") ) \
	and UIManager.previous_ui == UIManager.ui_list.get(UIEnums.UI.REBIRTH_SHOP):
		_cancel()
		# To gain focus again, toggling twice is a bit stupid though, maybe a bool
		# parameter would be more intuitive
		UIManager.toggle_ui(UIEnums.UI.REBIRTH_SHOP) # Close UI
		UIManager.toggle_ui(UIEnums.UI.REBIRTH_SHOP) # Open UI
		UIManager.get_viewport().set_input_as_handled()


func _cancel() -> void:
	UIManager.remove_ui(self)
	
func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.REBIRTH_SHOP)
	
	
func _refresh_shop() -> void:
	print("Refreshing Shop - Upgrades: ", SaveManager.get_loaded_player_upgrades())
	for child in items.get_children():
		child.queue_free()
		
	var copied_stats = SaveManager.get_loaded_player_stats()
	
	var skill_tree_item_damage = SKILL_TREE_ITEM.instantiate()
	skill_tree_item_damage.upgrade_type = "Damage"
	skill_tree_item_damage.upgrade_resources = [
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level1.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level2.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level3.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level4.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level5.tres"),
	]
	skill_tree_item_damage.copied_stats = copied_stats
	var skill_tree_item_health = SKILL_TREE_ITEM.instantiate()
	skill_tree_item_health.upgrade_type = "Health"
	skill_tree_item_health.upgrade_resources = [
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/health_level1.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/health_level2.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/health_level3.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/health_level4.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/health_level5.tres"),
	]
	skill_tree_item_health.copied_stats = copied_stats
	var skill_tree_item_speed = SKILL_TREE_ITEM.instantiate()
	skill_tree_item_speed.upgrade_type = "Speed"
	skill_tree_item_speed.upgrade_resources = [
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/speed_level1.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/speed_level2.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/speed_level3.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/speed_level4.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/speed_level5.tres"),
	]
	var skill_tree_item_defense = SKILL_TREE_ITEM.instantiate()
	skill_tree_item_defense.upgrade_type = "Defense"
	skill_tree_item_defense.upgrade_resources = [
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/defense_level1.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/defense_level2.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/defense_level3.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/defense_level4.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/defense_level5.tres"),
	]
	skill_tree_item_defense.copied_stats = copied_stats
	var skill_tree_item_stamina = SKILL_TREE_ITEM.instantiate()
	skill_tree_item_stamina.upgrade_type = "Stamina"
	skill_tree_item_stamina.upgrade_resources = [
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/stamina_level1.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/stamina_level2.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/stamina_level3.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/stamina_level4.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/stamina_level5.tres"),
	]
	skill_tree_item_stamina.copied_stats = copied_stats
	var skill_tree_item_weight = SKILL_TREE_ITEM.instantiate()
	skill_tree_item_weight.upgrade_type = "Weight"
	skill_tree_item_weight.upgrade_resources = [
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/weight_level1.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/weight_level2.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/weight_level3.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/weight_level4.tres"),
		preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/weight_level5.tres"),
	]
	skill_tree_item_weight.copied_stats = copied_stats
	

	
	items.add_child(skill_tree_item_damage)
	var separator1 = HSeparator.new()
	separator1.add_theme_constant_override("separation", 25)
	items.add_child(separator1)
	
	items.add_child(skill_tree_item_health)
	var separator2 = HSeparator.new()
	separator2.add_theme_constant_override("separation", 25)
	items.add_child(separator2)
	
	items.add_child(skill_tree_item_speed)
	var separator3 = HSeparator.new()
	separator3.add_theme_constant_override("separation", 25)
	items.add_child(separator3)

	items.add_child(skill_tree_item_defense)
	var separator4 = HSeparator.new()
	separator4.add_theme_constant_override("separation", 25)
	items.add_child(separator4)

	items.add_child(skill_tree_item_stamina)
	var separator5 = HSeparator.new()
	separator5.add_theme_constant_override("separation", 25)
	items.add_child(separator5)

	items.add_child(skill_tree_item_weight)
	var separator6 = HSeparator.new()
	separator6.add_theme_constant_override("separation", 25)
	items.add_child(separator6)
	
	
