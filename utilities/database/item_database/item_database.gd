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
	var subdirs: PackedStringArray = ResourceLoader.list_directory(path)
	for subdir in subdirs:
		if not subdir.ends_with("/"):
			continue
		var subdir_path := path.path_join(subdir.trim_suffix("/"))
		var files: PackedStringArray = ResourceLoader.list_directory(subdir_path)
		var tres_file: String = ""
		var tscn_file: String = ""

		for file in files:
			if file.begins_with(".") or file.ends_with("/"):
				continue
			if file.ends_with(".tres") and tres_file == "":
				tres_file = file
			elif file.ends_with(".tscn") and tscn_file == "":
				tscn_file = file

		if tres_file != "":
			var resource: Resource = ResourceLoader.load(subdir_path.path_join(tres_file))
			if resource is BaseResource:
				temp_items.append(resource)
		elif tscn_file != "" and resource_property != "":
			var scene := ResourceLoader.load(subdir_path.path_join(tscn_file)) as PackedScene
			if scene:
				var instance: Node = scene.instantiate()
				if instance and instance.has_method("get"):
					var hidden_resource = instance.get(resource_property)
					if hidden_resource is BaseResource:
						temp_items.append(hidden_resource)
				instance.queue_free()
