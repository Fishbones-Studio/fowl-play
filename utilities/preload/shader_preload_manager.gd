class_name ShaderPreloadManager
extends Node

@onready var preloader: ShaderPreloader

var _total_scenes_to_preload: int = 0

func _ready() -> void:
	preloader = ShaderPreloader.new()
	add_child(preloader)

	# Connect signals
	preloader.preloading_started.connect(_on_preloading_started)
	preloader.preloading_progress.connect(_on_preloading_progress)
	preloader.preloading_completed.connect(_on_preloading_completed)
	preloader.preloading_failed.connect(_on_preloading_failed)

func start_shader_preloading() -> void:
	print("Starting shader preloading...")
	preloader.start_preloading()

func _on_preloading_started(total_scenes: int) -> void:
	_total_scenes_to_preload = total_scenes
	print("Starting to preload ", total_scenes, " scenes")

func _on_preloading_progress(current_scene_index: int, scene_path: String) -> void:
	if _total_scenes_to_preload > 0:
		# current_scene_index starts at 0, so add 1 for progress display
		var progress: int = round(((current_scene_index + 1) * 100.0) / _total_scenes_to_preload)
		print("Progress: ", progress, "% - Loading: ", scene_path.get_file())
	else:
		print("Loading: ", scene_path.get_file(), " (Total scenes not determined yet)")

func _on_preloading_completed() -> void:
	print("All shaders and materials preloaded successfully!")

func _on_preloading_failed(error: String) -> void:
	print("Preloading failed: ", error)

# This function is called to initiate the shader preloading process
func preload_all_shaders() -> void:
	start_shader_preloading()

	# Wait for completion
	await preloader.preloading_completed
