@tool
extends BTAction

## Radius in which the enemy patrols.
@export var patrol_radius: float = 8.0
## Time between destination changes.
@export var patrol_interval: float = 2.0
## The minimun distance which we consider target reached to return SUCCESS.
@export var min_distance: float = 0.5
## If we want to have chaotic movement patterns.
@export var chaotic: bool = false
## The frequency of the enemy changing direction during chaotic movement.
@export var wave_frequency: float = 2.0
## The intensity of how far the enemy deviates during chaotic movement.
@export var wave_amplitude: float = 15.0

var speed: float:
	get:
		return agent.stats.calculate_speed(agent.movement_component.walk_speed_factor)

var _target_position: Vector3
var _origin_position: Vector3
var _current_timer: float = 0.0
var _wave_timer: float = 0.0


func _generate_name() -> String:
	return "Patrol ➜ %.1fm %s" % [patrol_radius, "(Chaotic)" if chaotic else ""]


func _enter() -> void:
	_origin_position = agent.global_position
	_current_timer = 0.0
	_wave_timer = 0.0
	_choose_new_patrol_target()


func _tick(delta: float) -> Status:
	_current_timer += delta
	_wave_timer += delta

	if agent.global_position.distance_to(_target_position) < min_distance:
		return SUCCESS

	if _current_timer >= patrol_interval:
		_choose_new_patrol_target()
		_current_timer = 0.0

	if not agent.is_immobile:
		_update_rotation(delta)
		_move_to_position(delta)

	return RUNNING


# TODO, fix unreachable y axis in patrol target sometimes, probably need to use navigation mesh
func _choose_new_patrol_target() -> void:
	var random_angle: float = randf_range(0, TAU)
	var random_distance: float= randf_range(0.5 * patrol_radius, patrol_radius)

	_target_position = _origin_position + Vector3(
		cos(random_angle) * random_distance,
		0,
		sin(random_angle) * random_distance
	)


func _move_to_position(_delta: float) -> void:
	var base_direction: Vector3 = agent.global_position.direction_to(_target_position)
	var movement: Vector3 = base_direction * speed

	if chaotic:
		var perpendicular: Vector3 = Vector3(base_direction.z, 0, -base_direction.x)
		movement += perpendicular * sin(_wave_timer * wave_frequency * TAU) * wave_amplitude

	agent.velocity = movement


func _update_rotation(delta: float) -> void:
	var direction: Vector3 = (_target_position - agent.global_position).normalized()
	var target_angle: float = atan2(-direction.x, -direction.z)

	agent.rotation.y = lerp_angle(agent.rotation.y, target_angle, min(speed * delta, 1.0))
