## Database for permanent upgrades in the rebirth shop
class_name PermUpgradeDatabase
extends BaseDatabase

const UPGRADE_PATH: String = "res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/"

static func _load_resources() -> Array[BaseResource]:
	var all_items: Array[BaseResource] = []
	var files: PackedStringArray       = get_files_from_path(UPGRADE_PATH)
	for upgrade_type in StatsEnums.UpgradeTypes.values():
		var upgrade_type_string: String = StatsEnums.upgrade_type_to_string(upgrade_type).to_lower()
		for file in files:
			if file.begins_with(upgrade_type_string) and file.ends_with(".tres"):
				var resource: Resource = load(UPGRADE_PATH.path_join(file))
				if resource is BaseResource:
					all_items.append(resource)
	return all_items


func get_upgrades_by_type(upgrade_type) -> Array[BaseResource]:
	var upgrades: Array[BaseResource] = []
	var upgrade_type_string: String = StatsEnums.upgrade_type_to_string(upgrade_type).to_lower()
	var files: PackedStringArray    = get_files_from_path(UPGRADE_PATH)
	for file in files:
		if file.begins_with(upgrade_type_string) and file.ends_with(".tres"):
			var resource: Resource = load(UPGRADE_PATH.path_join(file))
			if resource is BaseResource:
				upgrades.append(resource)
	return upgrades

func get_all_upgrades_grouped() -> Dictionary[StatsEnums.UpgradeTypes, Array]:
	var grouped: Dictionary[StatsEnums.UpgradeTypes, Array] = {}
	var files = get_files_from_path(UPGRADE_PATH)
	for upgrade_type in StatsEnums.UpgradeTypes.values():
		var upgrade_type_string: String = StatsEnums.upgrade_type_to_string(upgrade_type)
		grouped[upgrade_type] = []
		for file in files:
			if file.begins_with(upgrade_type_string) and file.ends_with(".tres"):
				var resource: Resource = load(UPGRADE_PATH.path_join(file))
				if resource is BaseResource:
					grouped[upgrade_type].append(resource)
	return grouped
