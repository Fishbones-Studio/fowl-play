class_name CustomLayerLabel3D
extends Label3D

@export_range(1, 20) var visual_layer: int = 3
## When true, makes the label rotate towards the player
@export var label_lookat_player := false :
	set(value):
		label_lookat_player = value
		set_process(value)

func _ready() -> void:
	layers = 1 << (visual_layer - 1)

func _process(delta: float) -> void:
	if GameManager.chicken_player:
		# Make the Label3D look at the player's global position.
		look_at(GameManager.chicken_player.global_position, Vector3.UP)
		# Rotate the label 180 degrees around its local Y-axis to face correctly.
		rotate_object_local(Vector3.UP, PI)
