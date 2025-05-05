class_name StatsEnums

enum Stats {
	MAX_HEALTH,
	MAX_STAMINA,
	ATTACK,
	DEFENSE,
	SPEED,
	WEIGHT,
	HEALTH_REGEN,
	STAMINA_REGEN
}

enum UpgradeTypes {
	DAMAGE,
	MAX_HEALTH,
	SPEED,
	DEFENSE,
	STAMINA,
	WEIGHT
}

static func upgrade_type_to_string(upgrade_type: UpgradeTypes) -> String:
	return UpgradeTypes.keys()[upgrade_type].to_lower()

static func stat_to_string(stat: Stats) -> String:
	return Stats.keys()[stat].to_lower()
