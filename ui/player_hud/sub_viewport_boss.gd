extends SubViewport

@export var offset : Vector3 = Vector3(0.0, 2.5, -7.0)
@onready var camera : Camera3D = %ViewportCameraBoss


func _process(_delta: float) -> void:
	if GameManager.current_enemy:
		var boss = GameManager.current_enemy

		# Position camera behind the boss
		var rotated_offset = boss.transform.basis * offset
		camera.global_position = boss.global_position + rotated_offset

		# Calculate a target point in front of the boss
		var target_position = boss.global_position + boss.transform.basis.z * 5.0
		target_position.y = camera.global_position.y  # Match camera's height

		# Look at the forward point
		camera.look_at(target_position)
