class_name DamageEnums

enum DamageTypes {
	NORMAL,
	TRUE, # Ignores defense when dealing damage, mostly for hazards
}


static func damage_type_to_string(damage_type: DamageTypes) -> String:
	return DamageTypes.keys()[damage_type].capitalize()
