extends Control

const SKILL_TREE_ITEM = preload("uid://cdudy6ia0qr8w")


@export var item_database: PermUpgradeDatabase
@export var refund_percentage := 0.8 ## For balancing purpouses, might change the refund amount

@onready var shop_title_label: Label = %ShopLabel
@onready var items: VBoxContainer = %Items
@onready var reset_label : RichTextLabel = %ResetLabel

func _ready() -> void:
	shop_title_label.text = "Rebirth Shop"
	_refresh_shop()
	_setup_controller_navigation()
	visibility_changed.connect(
		func():
			if visible:
				_setup_controller_navigation()
	)
	reset_label.text = "[center][font_size=25][color=gray][i]Resetting refunds [color=orange]%.f%%[/color] of currency spent.[/i][/color][/font_size][/center]" % (refund_percentage * 100)

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
		for upgrade_resource in upgrades_raw:
			if upgrade_resource is PermUpgradesResource:
				var skill_tree_item: SkillTreeItem = SKILL_TREE_ITEM.instantiate()
				items.add_child(skill_tree_item)
				skill_tree_item.init(upgrade_type, upgrade_resource, copied_stats)
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
	var upgrades: Dictionary[StatsEnums.UpgradeTypes, int] = SaveManager.get_loaded_player_upgrades()
	var total_feathers_refund := 0
	var total_eggs_refund := 0

	var available_upgrades: Dictionary = _get_available_items_grouped()

	# Iterate through the types of upgrades the player currently has
	for upgrade_type in upgrades.keys():
		var current_level: int = upgrades[upgrade_type]

		if current_level > 0:
			# Get the array of defined upgrade resources (levels) for this type
			var upgrade_levels_data: Array = available_upgrades.get(upgrade_type, [])

			if upgrade_levels_data.is_empty():
				printerr(
					"Warning: No upgrade level data found for type: ",
					StatsEnums.UpgradeTypes.get(upgrade_type),
					" during refund calculation."
				)
				continue # Skip to the next upgrade type

			# Get the base upgrade resource (level 1)
			var base_upgrade = upgrade_levels_data[0] if upgrade_levels_data.size() > 0 else null
			if not base_upgrade is PermUpgradesResource:
				printerr(
					"Warning: Invalid base upgrade resource for type: ",
					StatsEnums.UpgradeTypes.get(upgrade_type)
				)
				continue

			# Calculate total cost paid for all levels using the new cost calculation
			var total_cost = base_upgrade.get_level_cost(current_level)
			var refund: int = int(total_cost * refund_percentage)
			
			match base_upgrade.currency_type:
				CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
					total_feathers_refund += refund
				CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
					total_eggs_refund += refund

			# Debug print for verification
			print(
				"Refunding ", upgrade_type, 
				" (Level ", current_level, 
				"): Cost=", total_cost, 
				" Refund=", refund
			)

	# Apply the calculated refunds
	GameManager.feathers_of_rebirth += total_feathers_refund
	GameManager.prosperity_eggs += total_eggs_refund
	print(
		"Total Refunded: ",
		total_feathers_refund,
		" Feathers, ",
		total_eggs_refund,
		" Eggs."
	)

	# Reset the saved game data 
	SaveManager.reset_game()

	# Refresh the UI to show 0 levels and updated currency
	_refresh_shop()
