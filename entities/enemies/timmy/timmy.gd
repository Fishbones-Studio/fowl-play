extends Enemy

const RAY_LENGTH: float = 100.0

@export_group("Hover Settings")
@export var hover_height: float = 3.5
@export var hover_speed: float = 2.1


func apply_gravity(delta: float) -> void:
	var origin: Vector3 = global_transform.origin
	var target: Vector3 = origin - Vector3.UP * RAY_LENGTH

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, target)
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		var desired_y: float = result.position.y + hover_height
		origin.y = lerp(origin.y, desired_y, hover_speed * delta)
		global_transform.origin = origin
