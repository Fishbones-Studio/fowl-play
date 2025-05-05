extends SubViewport

enum EntityTypes { Chicken, Enemy }

@export var offset: Vector3 = Vector3(0.0, 1.5, -1.8)
@export var camera: Camera3D
@export var entity_types: EntityTypes

var entity: Node3D = null



func _process(_delta: float) -> void:
	match entity_types:
		EntityTypes.Chicken:
			if GameManager.chicken_player: 
				entity = GameManager.chicken_player
		EntityTypes.Enemy:
			if GameManager.current_enemy:
				entity = GameManager.current_enemy

	if entity: _update_camera()



func _update_camera() -> void:
	# Position camera behind the target
	var rotated_offset = entity.transform.basis * offset
	camera.global_position = entity.global_position + rotated_offset

	# Calculate a target point in front of the entity
	var target_position = entity.global_position + entity.transform.basis.z * 5.0
	target_position.y = camera.global_position.y  # Match camera's height

	# Look at the forward point
	camera.look_at(target_position)
