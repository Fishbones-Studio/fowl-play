extends Enemy

const RAY_LENGTH: float = 100.0

@export_group("Hover Settings")
@export var hover_height: float = 2.0
@export var hover_speed: float = 6.0
@export var sway_amount: float = 0.3
@export var sway_speed: float = 1.5
@export var bob_amount: float = 0.2 
@export var bob_speed: float = 2.0
@export var sway_offset: float = 1.0

var _time: float = 0.0
var _base_height: float = 0.0
var _sway_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	_base_height = global_position.y
	_sway_offset = Vector2(
		randf_range(-sway_offset, sway_offset), 
		randf_range(-sway_offset, sway_offset)
	)

	super()


func _apply_gravity(delta: float) -> void:
	_time += delta

	var bob: float = sin(_time * bob_speed) * bob_amount
	var origin: Vector3 = global_position
	var target: Vector3 = origin - Vector3.UP * RAY_LENGTH

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, target)
	query.collision_mask = 1 << 0 # Only detects world
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		var ground_position: Vector3 = result["position"]

		# Apply hover height with bobbing and vertical offset
		var desired_height: float = ground_position.y + hover_height + bob
		if desired_height > origin.y:
			velocity.y += hover_speed * delta
		else:
			velocity.y -= hover_speed * delta
	else:
		velocity.y += hover_speed * delta
