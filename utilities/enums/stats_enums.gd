class_name StatsEnums

enum Stat {
	MAX_HEALTH,
	MAX_STAMINA,
	ATTACK_MULTIPLIER,
	DEFENSE,
	SPEED,
	WEIGHT,
	HEALTH_REGEN,
	STAMINA_REGEN,
}

static func stat_to_string(stat: Stat) -> String:
	return Stat.keys()[stat].to_lower()
