## This scene loader is used as a parent for all gameplay scenes
##
## This allows for a single point of entry for all scenes, seperate from UI elements
extends Node

func _ready() -> void:
	SignalManager.switch_game_scene.connect(_on_switch_game_scene)


func _on_switch_game_scene(scene_path: String) -> void:
	# Remove the current children
	for child in get_children():
		child.queue_free()

	_on_add_game_scene(scene_path)


# TODO: maybe loading optimization? We will prob not run into that issue, but it could be a good idea to load the scene in the background
func _on_add_game_scene(scene_path: String) -> void:
	# Load the scene from the path
	var new_scene_resource: Resource = ResourceLoader.load(scene_path)

	if new_scene_resource == null:
		push_error("Error: Could not load scene at path: ", scene_path)
		return  # Exit if the scene failed to load

	# Check if the loaded resource is a PackedScene
	if new_scene_resource is PackedScene:
		# Instance the new scene
		var new_scene: Node = new_scene_resource.instantiate()

		# Add it as a child of the scene loader
		add_child(new_scene)
	else:
		push_error("Error: Resource at path is not a PackedScene: ", scene_path)
