## UI manager
## This script manages the UI scenes in the game.
## It handles switching between different UI scenes and loading them dynamically.
extends CanvasLayer

@export var initial_ui_scene: PackedScene


func _ready():
	SignalManager.switch_ui_scene.connect(_on_switch_ui)
	SignalManager.add_ui_scene.connect(_on_add_ui_scene)
	if initial_ui_scene:
		add_child(initial_ui_scene.instantiate())


func _on_switch_ui(new_ui_scene_path: String) -> void:
	# Remove the current children
	for child in get_children():
		child.queue_free()

	# Load the new UI scene from the path
	_on_add_ui_scene(new_ui_scene_path)


func _on_add_ui_scene(new_ui_scene_path: String) -> void:
	# Load the UI scene from the path
	var new_ui_scene_resource: Resource = ResourceLoader.load(new_ui_scene_path)

	if new_ui_scene_resource == null:
		push_error("Error: Could not load UI scene at path: ", new_ui_scene_path)
		return  # Exit if the scene failed to load

	# Check if the loaded resource is a PackedScene
	if new_ui_scene_resource is PackedScene:
		# Instance the new UI scene
		var new_ui_node: Node = new_ui_scene_resource.instantiate()

		# Add it as a child of the UI manager
		add_child(new_ui_node)
	else:
		push_error("Error: Resource at path is not a PackedScene: ", new_ui_scene_path)
