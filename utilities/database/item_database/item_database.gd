extends BaseDatabase


static func _load_resources() -> Array[BaseResource]:
	var temp_items: Array[BaseResource] = []
	load_scene_resources("res://entities/weapons/melee_weapons/melee_weapon_models", "current_weapon", temp_items)
	load_scene_resources("res://entities/weapons/ranged_weapons/ranged_weapon_models", "current_weapon", temp_items)
	return temp_items


static func load_scene_resources(path: String, resource_property: String, temp_items : Array[BaseResource]) -> void:

	var dir := DirAccess.open(path)
	if !dir:
		push_error("Can't open directory: ", path)
		return

	for subdir in dir.get_directories():
		var subdir_path := path.path_join(subdir)
		var sub_dir := DirAccess.open(subdir_path)
		var resource_loaded := false
		var tscn_file: String
		print("Looking in dir: " + subdir_path)

		# First try to load .tres file
		for file in sub_dir.get_files():
			if file.ends_with(".remap"):
				file = file.substr(0, file.length() - 6)  # Remove .remap
			if file.ends_with(".tres"):
				var resource: BaseResource = ResourceLoader.load(subdir_path.path_join(file)) as BaseResource
				if resource:
					temp_items.append(resource)
					resource_loaded = true
					break  # Found .tres, skip to next subdir
			if file.ends_with(".tscn"):
				tscn_file = subdir_path.path_join(file)
				break  # Save the .tscn file for later use

		# Fall back to scene loading if no .tres found
		if !resource_loaded && tscn_file:
			print("No .tres file found in ", subdir_path, ", loading scene instead")
			var scene := load(tscn_file) as PackedScene
			var instance: Node = scene.instantiate()

			if instance.has_method("get") && instance.get(resource_property) is BaseResource:
				temp_items.append(instance.get(resource_property))

			instance.queue_free()
			break  # Process only first .tscn per directory
