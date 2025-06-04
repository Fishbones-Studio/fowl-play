class_name SceneScanner
extends RefCounted

# Location to store the scene paths to preload
const CONFIG_FILE_PATH: String             = "user://shader_preload_config.json"
# Directories to exclude from scanning
const EXCLUDED_DIRECTORIES: Array[String] = ["addons", ".godot", ".import", "autoload", "ui", "sound", "art"]
# Scenes to exclude from preloading
const EXCLUDED_SCENES: Array[String]      = ["main.tscn", "ability.tscn", "enemy.tscn"]

static func scan_project_scenes() -> Array[String]:
	var all_candidate_scenes: Array[String] = []
	# Collect all .tscn files that are not in excluded directories or lists
	_collect_all_tscn_files("res://", all_candidate_scenes)

	var instanced_scenes_by_others: Dictionary = {}

	# Identify scenes that are instanced within other candidate scenes
	for scene_path in all_candidate_scenes:
		var packed_scene: PackedScene = load(scene_path)
		if packed_scene:
			# Instantiate with GEN_EDIT_STATE_DISABLED to avoid running _ready()
			# and to be able to inspect its structure safely.
			var temp_instance: Node = packed_scene.instantiate(
				PackedScene.GEN_EDIT_STATE_DISABLED
			)
			if temp_instance:
				_recursively_find_instanced_sub_scenes(
					temp_instance,
					instanced_scenes_by_others,
					scene_path # Pass the path of the scene currently being parsed
				)
				temp_instance.queue_free() # Clean up the temporary instance
			else:
				printerr(
					"SceneScanner: Failed to instantiate (disabled) ",
					scene_path
				)
		else:
			printerr("SceneScanner: Failed to load PackedScene for ", scene_path)

	# Filter to get only top-level scenes
	var scenes_to_preload: Array[String] = []
	for scene_path in all_candidate_scenes:
		if not instanced_scenes_by_others.has(scene_path):
			scenes_to_preload.append(scene_path)

	print(
		"SceneScanner: Found ",
		all_candidate_scenes.size(),
		" total candidate scenes."
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

# Helper to collect all .tscn files respecting basic exclusions
static func _collect_all_tscn_files(
	path: String,
	scene_paths_array: Array[String]
) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		printerr("SceneScanner: Failed to open directory: ", path)
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		var current_is_dir: bool = dir.current_is_dir()
		# path.path_join correctly handles slashes
		var full_path: String = path.path_join(file_name)

		# Skip hidden files/folders (like .godot, .import)
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue

		if current_is_dir:
			# Check if the directory name itself is in EXCLUDED_DIRECTORIES
			if full_path.get_file() in EXCLUDED_DIRECTORIES:
				file_name = dir.get_next()
				continue
			_collect_all_tscn_files(full_path, scene_paths_array)
		elif file_name.ends_with(".tscn"):
			# Check if the scene file name itself is in EXCLUDED_SCENES
			if not (file_name in EXCLUDED_SCENES):
				scene_paths_array.append(full_path)

		file_name = dir.get_next()

# Recursive helper to find scenes instanced within a given node's hierarchy
static func _recursively_find_instanced_sub_scenes(
	node: Node,
	instanced_scenes_set: Dictionary,
	current_parsing_scene_path: String
) -> void:
	# node.scene_file_path is the path of the .tscn file this node was instanced from.
	# If it's non-empty and different from the scene we are currently parsing, it means this 'node' is an instance of another scene (a sub-scene).
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
		print("Scene config saved with ", scene_paths.size(), " scenes")
	else:
		printerr("Failed to save scene config")

static func load_scene_config() -> Array[String]:
	var scene_paths: Array[String] = []
	var current_project_version: String = ProjectSettings.get_setting(
		"application/config/version",
		"unknown"
	)

	if not FileAccess.file_exists(CONFIG_FILE_PATH):
		print("SceneScanner: Config file not found, generating new one: ", CONFIG_FILE_PATH)
		generate_and_save_config() # This will create the file

	# Attempt to open and read the file after potential generation
	var file: FileAccess = FileAccess.open(CONFIG_FILE_PATH, FileAccess.READ)
	if file:
		var json_string: String = file.get_as_text()
		file.close() # Close file immediately after reading

		var json = JSON.new()
		var parse_result = json.parse(json_string)

		if parse_result == OK:
			var config_data = json.data
			var config_version: String = ""
			if config_data.has("version"):
				config_version = config_data.version

			if config_version != current_project_version:
				print(
					"SceneScanner: Config version mismatch (config: '",
					config_version,
					"', project: '",
					current_project_version,
					"'). Regenerating config."
				)
				generate_and_save_config()
				# Re-read the newly generated config
				file = FileAccess.open(CONFIG_FILE_PATH, FileAccess.READ)
				if file:
					json_string = file.get_as_text()
					file.close()
					parse_result = json.parse(json_string)
					if parse_result == OK:
						config_data = json.data
					else:
						printerr(
							"SceneScanner: Failed to parse newly generated config file JSON: ",
							json.get_error_message(),
							" at line ",
							json.get_error_line()
						)
						return scene_paths # Return empty if re-parse fails
				else:
					printerr("SceneScanner: Failed to open newly generated config file for reading: ", CONFIG_FILE_PATH)
					return scene_paths # Return empty if re-open fails

			# Proceed to load scenes if versions match or after successful regeneration
			if config_data.has("scenes") and config_data.scenes is Array:
				for scene_path_variant in config_data.scenes:
					if scene_path_variant is String:
						scene_paths.append(scene_path_variant)
				print("SceneScanner: Loaded ", scene_paths.size(), " scenes from config")
			else:
				printerr("SceneScanner: Invalid config file format (missing 'scenes' array).")
		else:
			printerr(
				"SceneScanner: Failed to parse config file JSON: ",
				json.get_error_message(),
				" at line ",
				json.get_error_line()
			)
			# Consider regenerating if parsing fails due to corruption, could be an old format
			print("SceneScanner: Config file might be corrupted. Attempting to regenerate.")
			generate_and_save_config()
			# Try to load one more time after regeneration
			file = FileAccess.open(CONFIG_FILE_PATH, FileAccess.READ)
			if file:
				json_string = file.get_as_text()
				file.close()
				parse_result = json.parse(json_string)
				if parse_result == OK:
					var fresh_config_data = json.data
					if fresh_config_data.has("scenes") and fresh_config_data.scenes is Array:
						for scene_path_variant in fresh_config_data.scenes:
							if scene_path_variant is String:
								scene_paths.append(scene_path_variant)
						print("SceneScanner: Loaded ", scene_paths.size(), " scenes from newly generated config")
				else:
					printerr("SceneScanner: Failed to parse regenerated config file.")
			else:
				printerr("SceneScanner: Failed to open regenerated config file.")

	else:
		printerr("SceneScanner: Failed to open config file for reading: ", CONFIG_FILE_PATH)
		print("SceneScanner: Attempting to generate config as a fallback.")
		generate_and_save_config()
		# No attempt to re-read here to avoid potential infinite loop if file system issues persist.

	return scene_paths

static func generate_and_save_config() -> void:
	print("Scanning project for scenes to preload...")
	var scene_paths: Array[String] = scan_project_scenes()
	save_scene_config(scene_paths)
