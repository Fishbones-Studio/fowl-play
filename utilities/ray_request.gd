class_name RayRequest
var origin: Vector3
var direction: Vector3
var max_range: float

func _init(_origin: Vector3, _direction: Vector3, _max_range: float):
	origin = _origin
	direction = _direction
	max_range = _max_range
