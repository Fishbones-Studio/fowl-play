class_name PermUpgradeDatabase
extends BaseDatabase

const UPGRADE_PATH: String = "res://ui/poultry_man_menu/rebirth_shop/perm_upgrades_resources/"


static func _load_resources() -> Array[BaseResource]:
	var all_items: Array[BaseResource] = []
	var files: PackedStringArray = _get_tres_files_from_path(UPGRADE_PATH)
	for upgrade_type in StatsEnums.UpgradeTypes.values():
		var upgrade_type_string: String = StatsEnums.upgrade_type_to_string(upgrade_type).to_lower()
		for file in files:
			if file.get_file().begins_with(upgrade_type_string):
				var resource: Resource = ResourceLoader.load(file)
				if resource is BaseResource:
					all_items.append(resource)
	return all_items


func get_upgrades_by_type(upgrade_type) -> Array[BaseResource]:
	var upgrades: Array[BaseResource] = []
	var upgrade_type_string: String = StatsEnums.upgrade_type_to_string(upgrade_type).to_lower()
	var files: PackedStringArray = _get_tres_files_from_path(UPGRADE_PATH)
	for file in files:
		if file.get_file().begins_with(upgrade_type_string):
			var resource: Resource = ResourceLoader.load(file)
			if resource is BaseResource:
				upgrades.append(resource)
	return upgrades


func get_all_upgrades_grouped() -> Dictionary[StatsEnums.UpgradeTypes, Array]:
	var grouped: Dictionary[StatsEnums.UpgradeTypes, Array] = {}
	var files: PackedStringArray = _get_tres_files_from_path(UPGRADE_PATH)
	for upgrade_type in StatsEnums.UpgradeTypes.values():
		var upgrade_type_string: String = StatsEnums.upgrade_type_to_string(upgrade_type)
		grouped[upgrade_type] = []
		for file in files:
			if file.get_file().begins_with(upgrade_type_string):
				var resource: Resource = ResourceLoader.load(file)
				if resource is BaseResource:
					grouped[upgrade_type].append(resource)
	return grouped


static func _get_tres_files_from_path(path: String) -> PackedStringArray:
	var files: PackedStringArray = []
	var file_names: PackedStringArray = ResourceLoader.list_directory(path)
	for file_name in file_names:
		if file_name.begins_with(".") or file_name.ends_with("/"):
			continue
		if file_name.ends_with(".tres"):
			files.append(path.path_join(file_name))
	return files
