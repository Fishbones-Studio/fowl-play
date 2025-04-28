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

static func stat_to_string(stat: Stats) -> String:
	return Stats.keys()[stat].to_lower()
