## This scene loader is used as a parent for all gameplay scenes
##
## This allows for a single point of entry for all scenes, seperate from UI elements
extends Node

# Variable to keep track of the scene currently being loaded in the background
var _loading_scene_path: String = ""

@onready var shader : PostProcess = $Shader
@onready var subviewport : LayerSubViewPort = %LayerViewPort

func _ready() -> void:
	SignalManager.switch_game_scene.connect(_on_switch_game_scene)
	SignalManager.remove_all_game_scenes.connect(_remove_all_game_scenes)
	# Disable processing by default, enable only when loading
	set_process(false)


func _process(_delta: float) -> void:
	# This function runs every frame, but only when set_process(true) is called. We use it to check the status of the background loading.

	# Should not happen, but safety check
	if _loading_scene_path.is_empty():
		set_process(false) # Disable processing if no path is set
		return

	# Check the status of the threaded load request
	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(
		_loading_scene_path
	)

	match load_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# Scene is still loading in the background.
			# Continuously update progress until loading is complete
			var progress_array: Array[Variant] = []
			ResourceLoader.load_threaded_get_status(_loading_scene_path, progress_array)
			# Emit current loading progress (fallback to 0.0 if not available)
			SignalManager.loading_progress_updated.emit(progress_array[0] if progress_array.size() > 0 else 0.0)
			pass # Keep checking next frame

		ResourceLoader.THREAD_LOAD_LOADED:
			# Loading finished successfully!
			print("Background scene load finished: ", _loading_scene_path)
			var loaded_resource: Resource = ResourceLoader.load_threaded_get(
				_loading_scene_path
			)

			# Store the path and reset the loading variable before instantiating, in case instantiation itself causes an error or another switch.
			var scene_to_instantiate_path: String = _loading_scene_path
			_loading_scene_path = ""
			# Notify that loading is complete
			SignalManager.loading_screen_finished.emit()
			set_process(false) # Stop checking status

			# Now instantiate the loaded scene
			_instantiate_and_add_scene(
				loaded_resource, scene_to_instantiate_path
			)

		ResourceLoader.THREAD_LOAD_FAILED:
			# An error occurred during loading.
			push_error(
				"Error: Failed to load scene thread: ", _loading_scene_path
			)
			_loading_scene_path = "" # Reset loading path
			set_process(false) # Stop checking status

		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			# The path provided was invalid.
			push_error(
				"Error: Invalid resource path for threaded load: ",
				_loading_scene_path
			)
			_loading_scene_path = "" # Reset loading path
			set_process(false) # Stop checking status


func _on_switch_game_scene(scene_enum: SceneEnums.Scenes) -> void:
	# If already loading something, the new request will overwrite the old one's tracking.
	# ResourceLoader handles multiple requests, but we'll only instantiate the last one requested.
	# The previous load will continue in the background but its result won't be used by this script.
	
	var scene_path : String = SceneEnums.PATHS[scene_enum]
	
	# If the scene path is null, throw error
	if scene_path == null:
		push_error("Provided scene path is null")
		return
	else:
		# If the scene path is empty, print a warning and return
		if scene_path.is_empty():
			push_warning("Scene path is empty, not loading anything.")
			return
		else:
			shader.show()
	

	if !_loading_scene_path.is_empty():
		print(
			"Warning: New scene requested while '%s' was still loading. Starting load for '%s'."
			% [_loading_scene_path, scene_path]
		)
		
	# Remove the current children immediately
	for child in get_children():
		if child is PostProcess or child is CanvasLayer : continue
		child.queue_free()
		

	# Start loading the new scene in a background thread
	var err: Error = ResourceLoader.load_threaded_request(scene_path)

	if err != OK:
		push_error(
			"Error: Could not start threaded load request for path: ",
			scene_path
		)
		return

	# Store the path we are now loading and enable processing to check status
	_loading_scene_path = scene_path
	set_process(true)
	print("Started loading scene in background: ", scene_path)


# Helper function to instantiate the scene once loaded
func _instantiate_and_add_scene(
	resource: Resource, scene_path: String
) -> void:
	if resource == null:
		# This case should ideally be caught by THREAD_LOAD_FAILED
		push_error("Error: Loaded resource is null for path: ", scene_path)
		return

	# Check if the loaded resource is a PackedScene
	if resource is PackedScene:
		# Instance the new scene
		var new_scene: Node = resource.instantiate()

		# Add it as a child of the scene loader
		add_child(new_scene)
		var cameras: Array[Node] = new_scene.get_tree().get_nodes_in_group("gameplay_camera")
		if cameras.size() > 0:
			print("Found gameplay camera")
			subviewport.active_camera = cameras[0]
		print("Scene instantiated and added: ", scene_path)
	else:
		push_error(
			"Error: Resource at path is not a PackedScene: ", scene_path
		)

func _remove_all_game_scenes() -> void:
	for child in get_children():
		if child is PostProcess or child is CanvasLayer : continue
		child.queue_free()
	set_process(false)
	subviewport.active_camera = null
