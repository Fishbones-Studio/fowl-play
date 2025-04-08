extends SubViewport

@export var offset : Vector3 = Vector3(0.0, 1.5, -1.8)
@onready var camera : Camera3D = $Camera3D

func _process(delta: float) -> void:
	if GameManager.chicken_player:
		var player = GameManager.chicken_player
		
		# Position camera behind the player
		var rotated_offset = player.transform.basis * offset
		camera.global_position = player.global_position + rotated_offset
		
		# Calculate a target point in front of the player
		var target_position = player.global_position + player.transform.basis.z * 5.0
		target_position.y = camera.global_position.y  # Match camera's height
		
		# Look at the forward point
		camera.look_at(target_position)
