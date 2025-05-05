extends BaseShop

const SKILL_TREE_ITEM = preload("uid://cdudy6ia0qr8w")

@onready var items: VBoxContainer = %Items

func _ready() -> void:
	shop_title_label.text = "Upgrades"
	super()

func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.REBIRTH_SHOP)

func _refresh_shop() -> void:
	for child in items.get_children():
		child.queue_free()

	var copied_stats                   = SaveManager.get_loaded_player_stats()
	var available_upgrades: Dictionary[StatsEnums.UpgradeTypes, Array] = _get_available_items_grouped()

	var upgrade_types: Array = StatsEnums.UpgradeTypes.values()
	for i in range(upgrade_types.size()):
		var upgrade_type = upgrade_types[i]
		print("Upgrade Type: ", upgrade_type)
		var upgrades_raw: Array = available_upgrades.get(upgrade_type, [])
		var upgrades: Array[PermUpgradeResource] = []
		for u in upgrades_raw:
			if u is PermUpgradeResource:
				upgrades.append(u)
		
		var skill_tree_item : SkillTreeItem = SKILL_TREE_ITEM.instantiate()
		items.add_child(skill_tree_item)
		skill_tree_item.init(upgrade_type, upgrades, copied_stats)
		if i < upgrade_types.size() - 1:
			var separator = HSeparator.new()
			separator.add_theme_constant_override("separation", 25)
			items.add_child(separator)

func create_shop_item(_selected_item) -> BaseShopItem:
	return null

func _get_available_items() -> Array:
	return []

func _get_available_items_grouped() -> Dictionary[StatsEnums.UpgradeTypes, Array]:
	if item_database is PermUpgradeDatabase:
		return item_database.get_all_upgrades_grouped()
	return {}

func _setup_controller_navigation() -> void:
	await get_tree().process_frame

	var focusable_items: Array = []
	for child in items.get_children():
		if child is SkillTreeItem:
			child.focus_mode = Control.FOCUS_ALL
			focusable_items.append(child)
		elif child is Control:
			child.focus_mode = Control.FOCUS_NONE

	if focusable_items.size() > 0:
		focusable_items[0].grab_focus()
