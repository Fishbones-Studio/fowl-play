class_name WeaponEnums
extends Node

enum WeaponState {
	IDLE,
	WINDUP,
	ATTACKING,
	COOLDOWN
}

## Helper function to convert the enum to a readable string
static func weapon_state_to_string(weapon_state: WeaponEnums.WeaponState) -> String:
	var weapon_state_string: String = WeaponEnums.WeaponState.keys()[weapon_state]
	# Turn item_string from UPPER_CASE to Title Case
	return weapon_state_string.capitalize()
