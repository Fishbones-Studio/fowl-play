extends Enemy

const RAY_LENGTH: float = 100.0

@export_group("Hover Settings")
@export var min_hover_height: float = 2.4
@export var max_hover_height: float = 6.6
@export var hover_speed: float = 3.3

var _current_hover_height: float = min_hover_height
var _ascending: bool = true


func apply_gravity(delta: float) -> void:
	var origin: Vector3 = global_transform.origin
	var target: Vector3 = origin - Vector3.UP * RAY_LENGTH

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, target)
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		_current_hover_height = clamp(_current_hover_height, min_hover_height, max_hover_height)

		if _ascending:
			_current_hover_height += hover_speed * delta
			if _current_hover_height >= max_hover_height:
				_current_hover_height = max_hover_height
				_ascending = false
		else:
			_current_hover_height -= hover_speed * delta
			if _current_hover_height <= min_hover_height:
				_current_hover_height = min_hover_height
				_ascending = true

		var desired_y: float = result.position.y + _current_hover_height
		origin.y = lerp(origin.y, desired_y, hover_speed * delta)
		global_transform.origin = origin
