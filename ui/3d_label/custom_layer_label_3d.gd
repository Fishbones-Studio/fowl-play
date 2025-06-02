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
	set_process(label_lookat_player)


func _process(_delta: float) -> void:
	if GameManager.chicken_player:
		var player_global_pos: Vector3 = GameManager.chicken_player.global_position
		
		# Create a target position that has the player's X and Z, but the label's own Y. This keeps the target on the same horizontal plane.
		var target_position_horizontal: Vector3 = Vector3(player_global_pos.x, global_position.y, player_global_pos.z)
		
		# Make the Label3D look at this horizontally-aligned target position.
		look_at(target_position_horizontal, Vector3.UP)
		
		# Rotate the label 180 degrees around its local Y-axis to face correctly.
		rotate_object_local(Vector3.UP, PI)
