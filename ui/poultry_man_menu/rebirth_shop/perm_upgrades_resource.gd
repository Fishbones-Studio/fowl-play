class_name PermUpgradesResource
extends BaseResource

@export_group("Permanent Upgrade Settings")
@export var upgrade_type: StatsEnums.UpgradeTypes
@export_group("Bonus")
@export var bonus: int = 0
@export var max_level: int = 6
@export var current_level: int = 0:
	set(value):
		current_level = clamp(value, 0, max_level)


func _init() -> void:
	type = ItemEnums.ItemTypes.PERM_UPGRADE
	currency_type = CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH


func get_upgrade_resource() -> UpgradeResource:
	var upgrade_resource: UpgradeResource = UpgradeResource.new()

	match upgrade_type:
		StatsEnums.UpgradeTypes.MAX_HEALTH:
			upgrade_resource.health_bonus = bonus
		StatsEnums.UpgradeTypes.DEFENSE:
			upgrade_resource.defense_bonus = bonus
		StatsEnums.UpgradeTypes.STAMINA:
			upgrade_resource.stamina_bonus = bonus
		StatsEnums.UpgradeTypes.WEIGHT:
			upgrade_resource.weight_bonus = bonus
		StatsEnums.UpgradeTypes.DAMAGE:
			upgrade_resource.attack_bonus = bonus
		StatsEnums.UpgradeTypes.SPEED:
			upgrade_resource.speed_bonus = bonus
		_:
			printerr("Unknown upgrade type: %s" % [str(upgrade_type)])

	return upgrade_resource


func get_modifier_string(hex_code: String = "#ffff00") -> Array[String]:
	var modifiers: Array[String] = []
	if bonus == 0:
		return modifiers

	modifiers.append("[color=%s]%+d[/color]" % [hex_code, int(bonus)])

	return modifiers


func get_level_cost(target_level: int) -> int:
	target_level = clamp(target_level, 0, max_level)
	if target_level == 0:
		return cost

	# Calculate the cost for the target level using geometric progression
	return target_level * cost
