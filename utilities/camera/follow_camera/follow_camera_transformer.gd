extends RemoteTransform3D

## A camera system that allows the camera to smoothly follow the player



@export var lerp_weight: float
@export var camera: Node3D


func _process(delta: float) -> void:
	position = lerp(position, camera.position, delta * lerp_weight)
