class_name SceneScanner
extends RefCounted

# Location to store the scene paths to preload
const CONFIG_FILE_PATH: String = "user://shader_preload_config.json"
# Directories to exclude from scanning
const EXCLUDED_DIRECTORIES: Array[String] = [
	"addons",
	".godot",
	".import",
	"export", # Exported game assets, doesn't contain anything actually used in the game
	"ui", # UI Scenes, minimal shader and material use
	"utilities",
	"resources",
	"art" # Art assets
]
# Scenes to exclude from preloading (filenames)
const EXCLUDED_SCENES: Array[String] = ["main.tscn", "ability.tscn", "enemy.tscn"]


# Helper to collect all .tscn files using ResourceLoader.list_directory
static func _collect_all_tscn_files_rl(
	current_dir_path: String,
	scene_paths_array: Array[String]
) -> void:
	# Ensure current_dir_path ends with a slash for consistency with list_directory
	var normalized_dir_path: String = current_dir_path
	if not normalized_dir_path.ends_with("/"):
		normalized_dir_path += "/"

	var entries: PackedStringArray = ResourceLoader.list_directory(normalized_dir_path)

	# list_directory returns an empty array if path doesn't exist or can't be read
	if entries.is_empty():
		# Optional: Check if the directory itself exists if needed for more detailed logging
		# if not ResourceLoader.has(normalized_dir_path): # This might not work for dirs
		# printerr("SceneScanner: Directory not found or inaccessible: ", normalized_dir_path)
		return # Nothing to process in this directory

	for entry_name in entries:
		# Skip hidden files/directories (e.g., .gdignore, .DS_Store)
		if entry_name.begins_with("."):
			continue

		var full_item_path: String = normalized_dir_path.path_join(entry_name)

		if entry_name.ends_with("/"): # It's a directory
			var dir_name_only: String = entry_name.trim_suffix("/")
			if dir_name_only in EXCLUDED_DIRECTORIES:
				continue # Skip this excluded directory
			# Recurse into subdirectories
			_collect_all_tscn_files_rl(full_item_path, scene_paths_array)
		elif entry_name.ends_with(".tscn"): # It's a file, check if it's a .tscn
			if not (entry_name in EXCLUDED_SCENES):
				scene_paths_array.append(full_item_path)


static func scan_project_scenes() -> Array[String]:
	var context_msg: String = "(Editor)" if Engine.is_editor_hint() else "(Exported Game)"
	print("SceneScanner: ", context_msg, " Starting scene scan using ResourceLoader.list_directory...")
	
	var all_candidate_scenes: Array[String] = []
	_collect_all_tscn_files_rl("res://", all_candidate_scenes)
	
	if all_candidate_scenes.is_empty():
		print(
			"SceneScanner: ", context_msg, " No .tscn files found after scan and filtering. This could mean:\n",
			"  - No scenes exist in the project that meet the criteria.\n",
			"  - All scenes were filtered out by EXCLUDED_DIRECTORIES or EXCLUDED_SCENES.\n",
			"  - ResourceLoader.list_directory could not access 'res://' or subdirectories (check export settings if in exported game)."
		)
	
	var instanced_scenes_by_others: Dictionary = {}

	for scene_path in all_candidate_scenes:
		var packed_scene: PackedScene = ResourceLoader.load(
			scene_path,
			"PackedScene",
			ResourceLoader.CACHE_MODE_IGNORE # Avoid issues with cached versions
		)
		if packed_scene:
			var temp_instance: Node = packed_scene.instantiate(
				PackedScene.GEN_EDIT_STATE_DISABLED
			)
			if temp_instance:
				_recursively_find_instanced_sub_scenes(
					temp_instance,
					instanced_scenes_by_others,
					scene_path
				)
				temp_instance.queue_free()
			else:
				printerr(
					"SceneScanner: Failed to instantiate (disabled) ",
					scene_path
				)
		else:
			printerr("SceneScanner: Failed to load PackedScene for ", scene_path)

	var scenes_to_preload: Array[String] = []
	for scene_path in all_candidate_scenes:
		if not instanced_scenes_by_others.has(scene_path):
			scenes_to_preload.append(scene_path)

	print(
		"SceneScanner: Found ",
		all_candidate_scenes.size(),
		" total candidate scenes after filtering."
	)
	print(
		"SceneScanner: Identified ",
		instanced_scenes_by_others.size(),
		" scenes that are instanced by others."
	)
	print(
		"SceneScanner: Will preload ",
		scenes_to_preload.size(),
		" top-level scenes."
	)
	return scenes_to_preload


static func _recursively_find_instanced_sub_scenes(
	node: Node,
	instanced_scenes_set: Dictionary,
	current_parsing_scene_path: String
) -> void:
	if (
		node.scene_file_path != ""
		and node.scene_file_path != current_parsing_scene_path
	):
		instanced_scenes_set[node.scene_file_path] = true

	for child_node in node.get_children():
		_recursively_find_instanced_sub_scenes(
			child_node,
			instanced_scenes_set,
			current_parsing_scene_path
		)


static func save_scene_config(scene_paths: Array[String]) -> void:
	var config_data: Dictionary = {
		"version": ProjectSettings.get_setting(
			"application/config/version",
			"unknown"
		),
		"generated_at": Time.get_datetime_string_from_system(),
		"scene_count": scene_paths.size(),
		"scenes": scene_paths
	}

	var file: FileAccess = FileAccess.open(CONFIG_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(config_data, "\t"))
		file.close()
		print(
			"SceneScanner: Scene config saved with ",
			scene_paths.size(),
			" scenes to ",
			CONFIG_FILE_PATH
		)
	else:
		printerr(
			"SceneScanner: Failed to save scene config to ", CONFIG_FILE_PATH
		)


static func load_scene_config() -> Array[String]:
	var scene_paths: Array[String] = []
	var current_project_version: String = ProjectSettings.get_setting(
		"application/config/version",
		"unknown"
	)
	var needs_regeneration: bool = false

	if not FileAccess.file_exists(CONFIG_FILE_PATH):
		print(
			"SceneScanner: Config file not found: ",
			CONFIG_FILE_PATH,
			". Flagging for regeneration."
		)
		needs_regeneration = true
	else:
		var file: FileAccess = FileAccess.open(CONFIG_FILE_PATH, FileAccess.READ)
		if file:
			var json_string: String = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)

			if parse_result == OK:
				var config_data = json.data
				if not config_data is Dictionary:
					printerr(
						"SceneScanner: Invalid config file format (root is not a Dictionary). Flagging for regeneration."
					)
					needs_regeneration = true
				else:
					var config_version: String = ""
					if config_data.has("version"):
						config_version = config_data.version

					if config_version != current_project_version:
						print(
							"SceneScanner: Config version mismatch (config: '",
							config_version,
							"', project: '",
							current_project_version,
							"'). Flagging for regeneration."
						)
						needs_regeneration = true
					else:
						if config_data.has("scenes") and config_data.scenes is Array:
							for scene_path_variant in config_data.scenes:
								if scene_path_variant is String:
									if ResourceLoader.exists(
										scene_path_variant,
										"PackedScene"
									):
										scene_paths.append(scene_path_variant)
									else:
										print(
											"SceneScanner: Scene from config not found or not a PackedScene: ",
											scene_path_variant
										)
							print(
								"SceneScanner: Loaded ",
								scene_paths.size(),
								" scenes from config."
							)
						else:
							printerr(
								"SceneScanner: Invalid config file format (missing 'scenes' array or wrong type). Flagging for regeneration."
							)
							needs_regeneration = true
			else:
				printerr(
					"SceneScanner: Failed to parse config file JSON: ",
					json.get_error_message(),
					" at line ",
					json.get_error_line(),
					". Flagging for regeneration."
				)
				needs_regeneration = true
		else:
			printerr(
				"SceneScanner: Failed to open config file for reading: ",
				CONFIG_FILE_PATH,
				". Flagging for regeneration."
			)
			needs_regeneration = true

	if needs_regeneration:
		print("SceneScanner: Attempting to regenerate scene config...")
		generate_and_save_config() # This calls scan_project_scenes

		scene_paths.clear() # Clear any paths loaded from an old/invalid config
		var new_file: FileAccess = FileAccess.open(
			CONFIG_FILE_PATH,
			FileAccess.READ
		)
		if new_file:
			var new_json_string: String = new_file.get_as_text()
			new_file.close()
			var new_json = JSON.new()
			var new_parse_result = new_json.parse(new_json_string)
			if new_parse_result == OK:
				var new_config_data = new_json.data
				if new_config_data is Dictionary and new_config_data.has("scenes") and new_config_data.scenes is Array:
					for scene_path_variant in new_config_data.scenes:
						if scene_path_variant is String:
							if ResourceLoader.exists(
								scene_path_variant,
								"PackedScene"
							):
								scene_paths.append(scene_path_variant)
							else:
								print(
									"SceneScanner: Scene from newly generated config not found/invalid: ",
									scene_path_variant
								)
					print(
						"SceneScanner: Loaded ",
						scene_paths.size(),
						" scenes from newly generated config."
					)
				else:
					printerr(
						"SceneScanner: Newly generated config is invalid (e.g., missing 'scenes' array or not a Dictionary)."
					)
			else:
				printerr(
					"SceneScanner: Failed to parse newly generated config JSON: ",
					new_json.get_error_message(),
					" at line ",
					new_json.get_error_line()
				)
		else:
			printerr(
				"SceneScanner: Failed to open newly generated config for reading: ",
				CONFIG_FILE_PATH
			)
			# If reading new config fails, scene_paths will be empty, which is the correct fallback.

	return scene_paths


static func generate_and_save_config() -> void:
	var context_msg: String = "(Editor)" if OS.has_feature("debug") else "(Exported Game)"
	print(
		"SceneScanner: ", context_msg, " Starting project scan to generate config..."
	)
	
	var scene_paths_to_save: Array[String] = scan_project_scenes()
	save_scene_config(scene_paths_to_save)