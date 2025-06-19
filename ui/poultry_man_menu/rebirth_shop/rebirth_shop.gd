extends UserInterface

signal stats_reset

const SKILL_TREE_ITEM = preload("uid://cdudy6ia0qr8w")

@export var item_database: PermUpgradeDatabase
@export var refund_percentage: float = 0.8

@onready var shop_title_label: Label = %ShopLabel
@onready var items: VBoxContainer = %Items
@onready var reset_label: RichTextLabel = %ResetLabel
@onready var close_button: Button = %CloseButton
@onready var reset_button: Button = %ResetButton
@onready var chicken_stat_container: ChickenStatsContainer = %ChickenStatsContainer


func _ready() -> void:
	super()
	shop_title_label.text = "Rebirth Shop"
	stats_reset.connect(_on_stats_reset)
	_refresh_shop()

	visibility_changed.connect(
		func():
			if visible:
				_setup_controller_navigation()
	)

	reset_label.text = "[center][font_size=25][color=gray][i]Resetting refunds [color=orange]%.f%%[/color] of currency spent.[/i][/color][/font_size][/center]" % (refund_percentage * 100)


func _on_close_button_pressed() -> void:
	UIManager.toggle_ui(UIEnums.UI.REBIRTH_SHOP)


func _refresh_shop() -> void:
	# Immediately remove and free old children
	for child in items.get_children():
		items.remove_child(child)
		child.free()

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

				# Connect the skill tree item signals
				skill_tree_item.skill_tree_item_focussed.connect(_on_skill_tree_item_focussed)
				skill_tree_item.skill_tree_item_unfocussed.connect(_on_skill_tree_item_unfocussed)
				skill_tree_item.upgrade_bought.connect(chicken_stat_container.update_base_values)
	
		if i < upgrade_types.size() - 1:
			var separator = HSeparator.new()
			separator.add_theme_constant_override("separation", 25)
			items.add_child(separator)

	# Re-run navigation setup after creating new items
	_setup_controller_navigation()


func _on_skill_tree_item_focussed(upgrade_type: StatsEnums.UpgradeTypes, bonus_value: float) -> void:
	if chicken_stat_container:
		chicken_stat_container.preview_stat_change(upgrade_type, bonus_value)


func _on_skill_tree_item_unfocussed(upgrade_type: StatsEnums.UpgradeTypes) -> void:
	if chicken_stat_container:
		chicken_stat_container.clear_stat_preview(upgrade_type)


func _get_available_items_grouped() -> Dictionary:
	if item_database is PermUpgradeDatabase:
		return item_database.get_all_upgrades_grouped()
	return {}


func _setup_controller_navigation() -> void:
	# Wait for the engine to process the newly added children
	await get_tree().process_frame

	var focusable_items: Array[Control] = []
	
	# Collect all SkillTreeItems
	for child in items.get_children():
		if child is SkillTreeItem:
			child.focus_mode = Control.FOCUS_ALL
			focusable_items.append(child)
		elif child is Control:
			# Ensure separators are not focusable
			child.focus_mode = Control.FOCUS_NONE

	# Set up close and reset buttons
	if close_button:
		close_button.focus_mode = Control.FOCUS_ALL
	if reset_button:
		reset_button.focus_mode = Control.FOCUS_ALL

	# Set up vertical navigation between skill tree items
	for i in range(focusable_items.size()):
		var current_item: Control = focusable_items[i]
		
		# Set up vertical navigation
		if i > 0:
			current_item.focus_neighbor_top = focusable_items[i - 1].get_path()
		else:
			# Prevent navigating up from the first item
			current_item.focus_neighbor_top = current_item.get_path()
			
		if i < focusable_items.size() - 1:
			current_item.focus_neighbor_bottom = focusable_items[i + 1].get_path()
		else:  # Last item connects to the reset button
			if reset_button:
				current_item.focus_neighbor_bottom = reset_button.get_path()

	# Set up bottom button navigation
	if reset_button and close_button:
		reset_button.focus_neighbor_right = close_button.get_path()
		reset_button.focus_neighbor_left = close_button.get_path()
		close_button.focus_neighbor_left = reset_button.get_path()
		close_button.focus_neighbor_right = reset_button.get_path()
		
		# Connect back to the last item
		if focusable_items.size() > 0:
			var last_item_path: NodePath = focusable_items[-1].get_path()
			reset_button.focus_neighbor_top = last_item_path
			close_button.focus_neighbor_top = last_item_path

	# Set initial focus
	if focusable_items.size() > 0:
		focusable_items[0].grab_focus()
	elif close_button: # Fallback if there are no items
		close_button.grab_focus()


func _get_refund_amount() -> Dictionary[CurrencyEnums.CurrencyTypes, int]:
	var refund_totals: Dictionary[CurrencyEnums.CurrencyTypes, int] = {
		CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH: 0,
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS: 0
	}

	var upgrades: Dictionary[StatsEnums.UpgradeTypes, int] = SaveManager.get_loaded_player_upgrades()
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
			var base_upgrade: PermUpgradesResource = upgrade_levels_data[0] if upgrade_levels_data.size() > 0 else null
			if not base_upgrade is PermUpgradesResource:
				printerr(
					"Warning: Invalid base upgrade resource for type: ",
					StatsEnums.UpgradeTypes.get(upgrade_type)
				)
				continue

			# Calculate total cost paid for all levels using the new cost calculation
			var total_cost: int = 0
			for level in range(current_level, 0, -1):
				total_cost += base_upgrade.get_level_cost(level)
			var refund: int = int(total_cost * refund_percentage)

			if refund_totals.has(base_upgrade.currency_type):
				refund_totals[base_upgrade.currency_type] += refund
			else:
				refund_totals[base_upgrade.currency_type] = refund

	return refund_totals


func _on_reset_button_pressed() -> void:
	SignalManager.add_ui_scene.emit(UIEnums.UI.REBIRTH_SHOP_RESET_STATS_POPUP, {
		"stats_reset_signal": stats_reset,
		"refund_percentage": refund_percentage * 100,
		"refund_amount": _get_refund_amount()
	})


func _on_stats_reset() -> void:
	var refund_amount: Dictionary[CurrencyEnums.CurrencyTypes, int] = _get_refund_amount()
	GameManager.feathers_of_rebirth += refund_amount.get(CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH, 0)
	GameManager.prosperity_eggs += refund_amount.get(CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS, 0)

	# Reset the player's upgrades and player's stats to default
	SaveManager.save_player_upgrades(SaveManager.get_default_upgrades())
	SaveManager.save_player_stats(SaveManager.get_default_player_stats())

	# Refresh the stats screen
	chicken_stat_container.update_base_values()

	# Rebuild the UI and the controller navigation
	_refresh_shop()
