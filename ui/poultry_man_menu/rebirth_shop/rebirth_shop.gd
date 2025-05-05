extends BaseShop

const SKILL_TREE_ITEM = preload("uid://cdudy6ia0qr8w")

# TODO: load these paths in dynamically
const UPGRADE_RESOURCES: Dictionary = {
										  "Damage": [
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level1.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level2.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level3.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level4.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/damage_level5.tres"),
										  ],
										  "Health": [
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/health_level1.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/health_level2.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/health_level3.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/health_level4.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/health_level5.tres"),
										  ],
										  "Speed": [
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/speed_level1.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/speed_level2.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/speed_level3.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/speed_level4.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/speed_level5.tres"),
										  ],
										  "Defense": [
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/defense_level1.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/defense_level2.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/defense_level3.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/defense_level4.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/defense_level5.tres"),
										  ],
										  "Stamina": [
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/stamina_level1.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/stamina_level2.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/stamina_level3.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/stamina_level4.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/stamina_level5.tres"),
										  ],
										  "Weight": [
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/weight_level1.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/weight_level2.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/weight_level3.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/weight_level4.tres"),
										  preload("res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/weight_level5.tres"),
										  ],
									  }

const UPGRADE_TYPES: Array = [
							 "Damage",
							 "Health",
							 "Speed",
							 "Defense",
							 "Stamina",
							 "Weight"
							 ]

@onready var items: VBoxContainer = %Items

func _ready() -> void:
	shop_title_label.text = "Upgrades"
	super()

func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.REBIRTH_SHOP)

func _refresh_shop() -> void:
	for child in items.get_children():
		child.queue_free()

	var copied_stats = SaveManager.get_loaded_player_stats()

	for i in UPGRADE_TYPES.size():
		var upgrade_type: String = UPGRADE_TYPES[i]
		var skill_tree_item = SKILL_TREE_ITEM.instantiate()
		skill_tree_item.upgrade_type = upgrade_type
		skill_tree_item.upgrade_resources = UPGRADE_RESOURCES[upgrade_type]
		skill_tree_item.copied_stats = copied_stats
		items.add_child(skill_tree_item)
		if i < UPGRADE_TYPES.size() - 1:
			var separator = HSeparator.new()
			separator.add_theme_constant_override("separation", 25)
			items.add_child(separator)

func create_shop_item(_selected_item) -> BaseShopItem:
	return null

func _get_available_items() -> Array:
	return []

func _setup_controller_navigation() -> void:
	await get_tree().process_frame

	var focusable_items: Array = []
	for child in items.get_children():
		# Only add skill tree items, not separators
		if child is SkillTreeItem:
			child.focus_mode = Control.FOCUS_ALL
			focusable_items.append(child)
		elif child is Control:
			child.focus_mode = Control.FOCUS_NONE

	if focusable_items.size() > 0:
		focusable_items[0].grab_focus()
