class_name ItemEnums
extends Node

enum ItemTypes {
	MELEE_WEAPON,
	RANGED_WEAPON,
	ABILITY,
	UPGRADE,
	PERM_UPGRADE,
}

## Helper function to convert the enum to a readable string
static func item_type_to_string(item_type: ItemTypes) -> String:
	var item_string: String = ItemTypes.keys()[item_type]
	# Turn item_string from UPPER_CASE to Title Case
	return item_string.capitalize()
