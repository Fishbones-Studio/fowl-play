extends SubViewport

enum EntityTypes { Chicken, Boss }

@export var offset: Vector3 = Vector3(0.0, 1.5, -1.8)
@export var camera: Camera3D
@export var entity_types: EntityTypes

var target: Node3D = null


func _process(_delta: float) -> void:
	match entity_types:
		EntityTypes.Chicken:
			if GameManager.chicken_player: 
				target = GameManager.chicken_player
		EntityTypes.Boss:
			if GameManager.current_enemy:
				target = GameManager.current_enemy
		_:
			push_error("Invalid entity type assigned to SubViewport")

	if target: _update_camera()


func _update_camera() -> void:
	# Position camera behind the target
	var rotated_offset = target.transform.basis * offset
	camera.global_position = target.global_position + rotated_offset

	# Calculate a target point in front of the entity
	var target_position = target.global_position + target.transform.basis.z * 5.0
	target_position.y = camera.global_position.y  # Match camera's height

	# Look at the forward point
	camera.look_at(target_position)
