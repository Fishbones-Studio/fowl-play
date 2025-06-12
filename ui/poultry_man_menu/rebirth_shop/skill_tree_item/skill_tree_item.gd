class_name SkillTreeItem
extends PanelContainer

signal skill_tree_item_focussed(upgrade_type: StatsEnums.UpgradeTypes, bonus_value: float)
signal skill_tree_item_unfocussed(upgrade_type: StatsEnums.UpgradeTypes)
signal upgrade_bought()

@export var upgrade_type: StatsEnums.UpgradeTypes

var copied_stats: LivingEntityStats
var upgrade_resource: PermUpgradesResource
var prosperity_egg_icon: CompressedTexture2D = preload("uid://be0yl1q0uryjp")
var feathers_of_rebirth_icon: CompressedTexture2D = preload("uid://brgdaqksfgmqu")

var hover_stylebox: StyleBoxFlat = preload("uid://c80bewaohqml0")
var normal_stylebox: StyleBoxFlat = preload("uid://ceyysiao8q2tl")

@onready var kind_indicator_label: Label = %KindIndicatorLabel
@onready var level_progress_bar: ProgressBar = %LevelProgressBar
@onready var level_label: Label = %LevelLabel
@onready var item_currency_icon: TextureRect = %ItemCurrencyIcon
@onready var item_cost_label: Label = %ItemCostLabel


func _ready() -> void:
	if not copied_stats:
		copied_stats = SaveManager.get_loaded_player_stats()
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(_on_focus_entered)
	mouse_exited.connect(_on_focus_exited)


func _gui_input(event: InputEvent) -> void:
	if not has_focus():
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if can_afford_upgrade():
				_on_buy_button_pressed()
				get_viewport().set_input_as_handled()
	# Handle purchase with controller/keyboard
	elif event.is_action_pressed("ui_accept"):
		if can_afford_upgrade():
			_on_buy_button_pressed()
			get_viewport().set_input_as_handled()


func init(
	_upgrade_type: StatsEnums.UpgradeTypes,
	_upgrade: PermUpgradesResource,
	_copied_stats: LivingEntityStats
) -> void:
	upgrade_type = _upgrade_type
	upgrade_resource = _upgrade
	upgrade_resource.current_level = SaveManager.get_loaded_player_upgrades().get(upgrade_type, 0)
	copied_stats = _copied_stats
	kind_indicator_label.text = StatsEnums.upgrade_type_to_string(_upgrade_type)
	update_ui_elements()


func _on_buy_button_pressed() -> void:
	if not upgrade_resource:
		return
	if upgrade_resource.current_level < upgrade_resource.max_level and can_afford_upgrade():
		purchase_upgrade()
		update_ui_elements()
		apply_upgrade()
		save_upgrades()
		upgrade_bought.emit()
		
		# Re-emit focus signal with updated bonus value
		if has_focus():
			_emit_focus_signal()
	else:
		print("Cannot purchase upgrade. Either max level reached or not enough currency.")


func _on_focus_entered() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", hover_stylebox)
	_emit_focus_signal()


func _on_focus_exited() -> void:
	if not theme:
		theme = Theme.new()
	theme.set_stylebox("panel", "PanelContainer", normal_stylebox)
	skill_tree_item_unfocussed.emit(upgrade_type)


func _emit_focus_signal() -> void:
	var bonus_value: float = _get_next_level_bonus()
	skill_tree_item_focussed.emit(upgrade_type, bonus_value)


func _get_next_level_bonus() -> float:
	if not upgrade_resource or upgrade_resource.current_level >= upgrade_resource.max_level:
		return 0.0
	
	var upgrade_bonus = upgrade_resource.get_upgrade_resource()
	if not upgrade_bonus:
		return 0.0
	
	match upgrade_type:
		StatsEnums.UpgradeTypes.MAX_HEALTH:
			return upgrade_bonus.health_bonus
		StatsEnums.UpgradeTypes.STAMINA:
			return upgrade_bonus.stamina_bonus
		StatsEnums.UpgradeTypes.DAMAGE:
			return upgrade_bonus.attack_bonus
		StatsEnums.UpgradeTypes.DEFENSE:
			return upgrade_bonus.defense_bonus
		StatsEnums.UpgradeTypes.SPEED:
			return upgrade_bonus.speed_bonus
		StatsEnums.UpgradeTypes.WEIGHT:
			return upgrade_bonus.weight_bonus
		_:
			return 0.0


func can_afford_upgrade() -> bool:
	if upgrade_resource.current_level >= upgrade_resource.max_level:
		return false
	match upgrade_resource.currency_type:
		CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
			return GameManager.feathers_of_rebirth >= upgrade_resource.get_level_cost(upgrade_resource.current_level+1)
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
			return GameManager.prosperity_eggs >= upgrade_resource.get_level_cost(upgrade_resource.current_level+1)
		_:
			return false


func purchase_upgrade() -> void:
	match upgrade_resource.currency_type:
		CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
			GameManager.feathers_of_rebirth -= upgrade_resource.get_level_cost(upgrade_resource.current_level+1)
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
			GameManager.prosperity_eggs -= upgrade_resource.get_level_cost(upgrade_resource.current_level+1)
	upgrade_resource.current_level += 1


func apply_upgrade() -> void:
	if upgrade_resource.current_level == 0 or upgrade_resource.current_level > upgrade_resource.max_level:
		return
	if upgrade_resource == null:
		push_error("Upgrade resource is null!")
		return
	if not upgrade_resource is PermUpgradesResource:
		push_error("Upgrade resource is not a PermUpgradeResource!")
		return
	match upgrade_type:
		StatsEnums.UpgradeTypes.MAX_HEALTH:
			copied_stats.max_health += upgrade_resource.get_upgrade_resource().health_bonus
		StatsEnums.UpgradeTypes.STAMINA:
			copied_stats.max_stamina += upgrade_resource.get_upgrade_resource().stamina_bonus
		StatsEnums.UpgradeTypes.DAMAGE:
			copied_stats.attack += upgrade_resource.get_upgrade_resource().attack_bonus
		StatsEnums.UpgradeTypes.DEFENSE:
			copied_stats.defense += upgrade_resource.get_upgrade_resource().defense_bonus
		StatsEnums.UpgradeTypes.SPEED:
			copied_stats.speed += upgrade_resource.get_upgrade_resource().speed_bonus
		StatsEnums.UpgradeTypes.WEIGHT:
			copied_stats.weight += upgrade_resource.get_upgrade_resource().weight_bonus
	SaveManager.save_player_stats(copied_stats)


func update_ui_elements() -> void:
	level_progress_bar.max_value = upgrade_resource.max_level
	level_progress_bar.value = upgrade_resource.current_level

	if upgrade_resource.current_level < upgrade_resource.max_level:
		item_cost_label.text = str(upgrade_resource.get_level_cost(upgrade_resource.current_level + 1))
		match upgrade_resource.currency_type:
			CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
				item_currency_icon.texture = prosperity_egg_icon
			_:
				item_currency_icon.texture = feathers_of_rebirth_icon
		item_cost_label.show()
		item_currency_icon.show()
	else:
		item_cost_label.hide()
		item_currency_icon.hide()

	if upgrade_resource.current_level < upgrade_resource.max_level:
		level_label.text = str(upgrade_resource.current_level)
	else:
		level_label.text = "MAX"


func save_upgrades() -> void:
	var upgrades: Dictionary[StatsEnums.UpgradeTypes, int] = SaveManager.get_loaded_player_upgrades()
	upgrades[upgrade_type] = upgrade_resource.current_level
	SaveManager.save_player_upgrades(upgrades)
