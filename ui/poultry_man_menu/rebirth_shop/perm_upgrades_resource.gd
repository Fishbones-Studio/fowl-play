class_name PermUpgradesResource
extends BaseResource

@export_group("Permanent Upgrade Settings")
@export var upgrade_type: StatsEnums.UpgradeTypes
@export_group("Bonus")
@export var bonus: int = 0
## How much bonus the upgrade applies more at each level
@export var bonus_level_step: int = bonus
# The multiplier for the bonus at each level
@export_range(1, 10) var bonus_level_multiplier: int = 1
## How much more the upgrade costs at each level
@export var cost_level_step: int = cost
## Multiplies cost of the upgrade at each level
@export_range(1, 10) var cost_level_multiplier: int = 1
@export var max_level: int = 6
@export var current_level: int = 0 :
	set(value):
		current_level = clamp(value, 0, max_level)
		# Update the cost of the upgrade based on the new level
		cost += get_next_level_cost()


func _init() -> void:
	type = ItemEnums.ItemTypes.PERM_UPGRADE
	currency_type = CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH

func get_upgrade_resource() -> UpgradeResource:
	var upgrade_resource: UpgradeResource = UpgradeResource.new()
	var value: int = bonus  * bonus_level_multiplier * (current_level + bonus_level_step)

	match upgrade_type:
		StatsEnums.UpgradeTypes.MAX_HEALTH:
			upgrade_resource.health_bonus = value
		StatsEnums.UpgradeTypes.DEFENSE:
			upgrade_resource.defense_bonus = value
		StatsEnums.UpgradeTypes.STAMINA:
			upgrade_resource.stamina_bonus = value
		StatsEnums.UpgradeTypes.WEIGHT:
			upgrade_resource.weight_bonus = value
		StatsEnums.UpgradeTypes.DAMAGE:
			upgrade_resource.attack_bonus = value
		StatsEnums.UpgradeTypes.SPEED:
			upgrade_resource.speed_bonus = value
		_:
			printerr("Unknown upgrade type: %s" % [str(upgrade_type)])

	return upgrade_resource

func get_modifier_string(hex_code: String = "#ffff00") -> Array[String]:
	var modifiers: Array[String] = []
	if bonus == 0:
		return modifiers

	modifiers.append("[color=%s]%+d[/color]" % [hex_code, int(bonus)])

	return modifiers
	
func get_next_level_cost(levels : int = 1 ) -> int:
	levels = clamp(levels, 0, max_level - current_level)
	if current_level == 0 || levels == 0:
		return cost
	return int(cost_level_multiplier * (current_level + levels) * cost_level_step)

func get_previous_level_cost(levels : int = 1) -> int:
	levels = clamp(levels, 0, current_level)
	if current_level == 0 or levels == 0:
		return cost
	return int(cost_level_multiplier * (current_level - levels) * cost_level_step)
