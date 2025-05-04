extends BaseDatabase


static func _load_resources() -> Array[BaseResource]:
	var temp_items: Array[BaseResource] = []
	load_scene_resources("res://entities/weapons/melee_weapons/melee_weapon_models", "current_weapon", temp_items)
	load_scene_resources("res://entities/weapons/ranged_weapons/ranged_weapon_models", "current_weapon", temp_items)
	load_scene_resources("res://entities/abilities/ability_models/", "", temp_items)
	return temp_items


static func load_scene_resources(
	path: String,
	resource_property: String,
	temp_items: Array[BaseResource]
) -> void:
	var dir := DirAccess.open(path)
	if !dir:
		push_error("Can't open directory: ", path)
		return

	for subdir in dir.get_directories():
		var subdir_path := path.path_join(subdir)
		var sub_dir := DirAccess.open(subdir_path)
		if !sub_dir:
			continue

		var tres_file: String = ""
		var tscn_file: String = ""

		# First try to load .tres file
		for file in sub_dir.get_files():
			if file.ends_with(".tres"):
				tres_file = file
				break  # Prefer .tres, stop searching
			elif file.ends_with(".tscn"):
				if tscn_file == "":
					tscn_file = file  # Use the first .tscn found

		if tres_file != "":
			var resource: Resource = load(subdir_path.path_join(tres_file))
			if resource is BaseResource and resource.purchasable:
				temp_items.append(resource)
		elif tscn_file != "":
			var scene := load(subdir_path.path_join(tscn_file)) as PackedScene
			var instance: Node = scene.instantiate()
			if instance.has_method("get"):
				var hidden_resource = instance.get(resource_property)
				if hidden_resource is BaseResource and hidden_resource.purchasable:
					temp_items.append(hidden_resource)
			instance.queue_free()

