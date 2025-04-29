class_name WeaponEnums
extends Node

enum WeaponType {
	MELEE,
	RANGED,
}

enum WeaponState {
	IDLE,
	WINDUP,
	ATTACKING,
	COOLDOWN
}


## Converts WeaponType enum to formatted string (e.g., "Melee")
static func weapon_type_to_string(weapon_type: WeaponType) -> String:
	return WeaponType.keys()[weapon_type].capitalize()


## Converts WeaponState enum to formatted string (e.g., "Attacking")
static func weapon_state_to_string(weapon_state: WeaponState) -> String:
	return WeaponState.keys()[weapon_state].capitalize()
