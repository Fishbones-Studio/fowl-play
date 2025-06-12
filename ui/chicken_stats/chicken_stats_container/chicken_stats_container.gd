class_name ChickenStatsContainer
extends VBoxContainer

# Dictionary to track which stats are currently being previewed
var _preview_values: Dictionary = {}

@onready var stat_containers: Array[StatContainer]


func _ready() -> void:
	stat_containers = []
	for child in get_children():
		if child is StatContainer:
			stat_containers.append(child)


## Preview a stat change for a specific upgrade type
func preview_stat_change(upgrade_type: StatsEnums.UpgradeTypes, bonus_value: float) -> void:
	var target_stat: StatsEnums.Stats = _upgrade_type_to_stat(upgrade_type)
	if target_stat == null:
		return
	
	# Store the preview value
	_preview_values[target_stat] = bonus_value
	
	# Find the corresponding stat container and update it
	for container in stat_containers:
		if container.stat == target_stat:
			container.show_preview_bonus(bonus_value)
			break


## Clear preview for a specific upgrade type
func clear_stat_preview(upgrade_type: StatsEnums.UpgradeTypes) -> void:
	var target_stat: StatsEnums.Stats = _upgrade_type_to_stat(upgrade_type)
	if target_stat == null:
		return

	# Remove from preview values
	_preview_values.erase(target_stat)

	# Find the corresponding stat container and clear preview
	for container in stat_containers:
		if container.stat == target_stat:
			container.clear_preview_bonus()
			break


## Clear all stat previews
func clear_all_previews() -> void:
	_preview_values.clear()
	for container in stat_containers:
		container.clear_preview_bonus()


## Update the base value for all stat containers
func update_base_values() -> void:
	for stat_container in stat_containers:
			var stat_name: String = StatsEnums.stat_to_string(stat_container.stat)
			stat_container.setup(SaveManager.get_loaded_player_stats().get(stat_name))


## Map upgrade types to stats
func _upgrade_type_to_stat(upgrade_type: StatsEnums.UpgradeTypes) -> StatsEnums.Stats:
	match upgrade_type:
		StatsEnums.UpgradeTypes.HEALTH:
			return StatsEnums.Stats.MAX_HEALTH
		StatsEnums.UpgradeTypes.STAMINA:
			return StatsEnums.Stats.MAX_STAMINA
		StatsEnums.UpgradeTypes.ATTACK:
			return StatsEnums.Stats.ATTACK
		StatsEnums.UpgradeTypes.DEFENSE:
			return StatsEnums.Stats.DEFENSE
		StatsEnums.UpgradeTypes.SPEED:
			return StatsEnums.Stats.SPEED
		StatsEnums.UpgradeTypes.WEIGHT:
			return StatsEnums.Stats.WEIGHT
		_:
			return StatsEnums.Stats.NONE
