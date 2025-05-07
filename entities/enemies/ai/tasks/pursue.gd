@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"
## How close should the agent be to the desired position to return SUCCESS.
@export var tolerance: float = 2.0
## Desired distance from target.
@export var aggro_distance: float = 20.0
## Pursuit speed factor.
@export var speed_factor: float = 0.0
## Duration the enemy will pursue the target.
@export var duration: float = 0.0
## Use path finding instead of normal movement
@export var pathfinding: bool = false
 ## Force immediate updates.
@export var immediate_response: bool = false
## Path update frequency.
@export var path_update_interval: float = 0.05

var target: ChickenPlayer

var _last_path_update: float = 0.0
var _current_direction: Vector3 = Vector3.ZERO
var _last_target_position: Vector3 = Vector3.ZERO # track target movement


func _generate_name() -> String:
	return "Pursue ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _enter() -> void:
	target = blackboard.get_var(target_var, null)

	if pathfinding:
		if not agent.nav.velocity_computed.is_connected(_on_velocity_computed):
			agent.nav.velocity_computed.connect(_on_velocity_computed, CONNECT_DEFERRED)
			var shape: Shape3D = agent.shape.shape
			if shape is CapsuleShape3D:
				agent.nav.radius = shape.radius
			if shape is BoxShape3D:
				agent.nav.radius = shape.size.x / 2.0

		agent.nav.target_desired_distance = tolerance


func _tick(delta: float) -> Status:
	if not is_instance_valid(target):
		return FAILURE

	var target_position: Vector3 = target.global_position
	var target_moved: bool = _last_target_position.distance_to(target_position) > 0.1 # check target movement
	
	if pathfinding:
		# Force immediate update if target moved significantly or we want immediate response
		if immediate_response or target_moved or _last_path_update >= path_update_interval:
			agent.nav.target_position = target_position
			_last_path_update = 0.0
		else:
			_last_path_update += delta

	_last_target_position = target_position

	if _is_at_position(target_position):
		return SUCCESS

	if duration > 0 and elapsed_time > duration:
		return SUCCESS

	_move_towards_target(target_position, delta, target_moved)
	return RUNNING


func _move_towards_target(target_pos: Vector3, _delta: float, target_moved: bool):
	var speed = speed_factor if speed_factor > 0.0 else agent.stats.calculate_speed(agent.movement_component.sprint_speed_factor)

	if pathfinding:
		_current_direction = (agent.nav.get_next_path_position() - agent.global_position).normalized()
		# Apply raw velocity immediately if target moved
		if immediate_response and target_moved:
			agent.velocity = _current_direction * speed
		# Still let avoidance work
		agent.nav.set_velocity(_current_direction * speed)
	else:
		_current_direction = agent.global_position.direction_to(target_pos)
		agent.velocity = _current_direction * speed


func _on_velocity_computed(safe_velocity: Vector3):
	# Always apply the computed velocity, but immediate responses already moved
	if not (immediate_response and _last_target_position.distance_to(target.global_position) > 0.1):
		agent.velocity = safe_velocity


func _is_at_position(position: Vector3) -> bool:
	return agent.global_position.distance_to(position) < tolerance
