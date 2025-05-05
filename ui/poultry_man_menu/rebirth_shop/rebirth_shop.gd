extends Control

const SKILL_TREE_ITEM = preload("uid://cdudy6ia0qr8w")


@export var item_database: PermUpgradeDatabase
@export var refund_percentage := 1.0 ## For balancing purpouses, might change the refund amount

@onready var shop_title_label: Label = %ShopLabel
@onready var items: VBoxContainer = %Items

func _ready() -> void:
	shop_title_label.text = "Upgrades"
	_refresh_shop()
	_setup_controller_navigation()
	visibility_changed.connect(
		func():
			if visible:
				_setup_controller_navigation()
	)

func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.REBIRTH_SHOP)

func _refresh_shop() -> void:
	for child in items.get_children():
		child.queue_free()

	var copied_stats = SaveManager.get_loaded_player_stats()
	var available_upgrades: Dictionary = _get_available_items_grouped()
	var upgrade_types: Array = StatsEnums.UpgradeTypes.values()

	for i in range(upgrade_types.size()):
		var upgrade_type = upgrade_types[i]
		var upgrades_raw: Array = available_upgrades.get(upgrade_type, [])
		var upgrades: Array[PermUpgradeResource] = []
		for u in upgrades_raw:
			if u is PermUpgradeResource:
				upgrades.append(u)

		var skill_tree_item: SkillTreeItem = SKILL_TREE_ITEM.instantiate()
		items.add_child(skill_tree_item)
		skill_tree_item.init(upgrade_type, upgrades, copied_stats)
		if i < upgrade_types.size() - 1:
			var separator = HSeparator.new()
			separator.add_theme_constant_override("separation", 25)
			items.add_child(separator)

func _get_available_items_grouped() -> Dictionary:
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


func _on_reset_button_pressed() -> void:
	var upgrades = SaveManager.get_loaded_player_upgrades()
	var total_feathers_refund := 0
	var total_eggs_refund := 0

	# Loop through all upgrade types
	for upgrade_type in upgrades.keys():
		var level = upgrades[upgrade_type]
		if level > 0:
			# Get the upgrade resources for this type
			var upgrades_raw: Array = _get_available_items_grouped().get(upgrade_type, [])
			for i in range(level):
				var upgrade_resource = upgrades_raw[i]
				if upgrade_resource is PermUpgradeResource:
					var refund = int(upgrade_resource.cost * refund_percentage)
					match upgrade_resource.currency_type:
						CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
							total_feathers_refund += refund
						CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
							total_eggs_refund += refund
			# Reset the upgrade level
			upgrades[upgrade_type] = 0

	# Apply the refunds
	GameManager.feathers_of_rebirth += total_feathers_refund
	GameManager.prosperity_eggs += total_eggs_refund

	# Reset player stats (optional, if you want to fully reset)
	SaveManager.reset_game()
	_refresh_shop()
