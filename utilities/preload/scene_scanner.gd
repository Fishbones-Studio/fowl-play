class_name SceneScanner
extends RefCounted

# Location to store the scene paths to preload
const CONFIG_FILE_PATH: String             = "user://shader_preload_config.json"
# Directories to exclude from scanning
const EXCLUDED_DIRECTORIES: Array[String] = ["addons", ".godot", ".import", "autoload", "ui"]
# Scenes to exclude from preloading
const EXCLUDED_SCENES: Array[String]      = ["main.tscn"]

static func scan_project_scenes() -> Array[String]:
	var scene_paths: Array[String] = []
	_scan_directory("res://", scene_paths)
	return scene_paths

static func _scan_directory(path: String, scene_paths: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		print("Failed to open directory: ", path)
		return
	
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	
	while file_name != "":
		var full_path: String = path + "/" + file_name
		
		# Skip hidden files and excluded directories
		if file_name.begins_with(".") or file_name in EXCLUDED_DIRECTORIES:
			file_name = dir.get_next()
			continue
		
		if dir.current_is_dir():
			# Recursively scan subdirectories
			_scan_directory(full_path, scene_paths)
		elif file_name.ends_with(".tscn"):
			# Check if this scene should be included
			if not file_name in EXCLUDED_SCENES:
				scene_paths.append(full_path)
		
		file_name = dir.get_next()
		

static func save_scene_config(scene_paths: Array[String]) -> void:
	var config_data: Dictionary = {
		"version": ProjectSettings.get_setting("application/config/version", "unknown"),
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
		print("Failed to save scene config")

static func load_scene_config() -> Array[String]:
	var scene_paths: Array[String] = []
	
	if not FileAccess.file_exists(CONFIG_FILE_PATH):
		print("Scene config file not found")
		return scene_paths
	
	var file: FileAccess = FileAccess.open(CONFIG_FILE_PATH, FileAccess.READ)
	if file:
		var json_string: String = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var config_data = json.data
			if config_data.has("scenes") and config_data.scenes is Array:
				for scene_path in config_data.scenes:
					if scene_path is String:
						scene_paths.append(scene_path)
				print("Loaded ", scene_paths.size(), " scenes from config")
			else:
				print("Invalid config file format")
		else:
			print("Failed to parse config file JSON")
	else:
		print("Failed to open config file")
	
	return scene_paths

static func generate_and_save_config() -> void:
	print("Scanning project for scenes...")
	var scene_paths: Array[String] = scan_project_scenes()
	save_scene_config(scene_paths)
