class_name ShaderPreloadManager
extends Node

@onready var preloader: ShaderPreloader

var _config_generation_complete: bool = false

func _ready() -> void:
	preloader = ShaderPreloader.new()
	add_child(preloader)
	
	# Connect signals
	preloader.preloading_started.connect(_on_preloading_started)
	preloader.preloading_progress.connect(_on_preloading_progress)
	preloader.preloading_completed.connect(_on_preloading_completed)
	preloader.preloading_failed.connect(_on_preloading_failed)

func generate_scene_config() -> void:
	print("Generating scene configuration...")
	SceneScanner.generate_and_save_config()
	_config_generation_complete = true
	print("Scene configuration generated successfully")

func start_shader_preloading() -> void:
	if not _config_generation_complete:
		print("Config not generated yet. Generating now...")
		generate_scene_config()
	
	print("Starting shader preloading...")
	preloader.start_preloading()

func _on_preloading_started(total_scenes: int) -> void:
	print("Starting to preload ", total_scenes, " scenes")

func _on_preloading_progress(current_scene: int, scene_path: String) -> void:
	var progress: int = (current_scene * 100) / preloader.get_child_count()
	print("Progress: ", progress, " - Loading: ", scene_path.get_file())

func _on_preloading_completed() -> void:
	print("All shaders and materials preloaded successfully!")

func _on_preloading_failed(error: String) -> void:
	print("Preloading failed: ", error)

# This function is called to initiate the shader preloading process
func preload_all_shaders() -> void:
	generate_scene_config()
	start_shader_preloading()
	
	# Wait for completion
	await preloader.preloading_completed
