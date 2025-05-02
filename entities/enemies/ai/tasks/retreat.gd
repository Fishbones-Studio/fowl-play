@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"
## How far should the agent retreat to return SUCCESS.
@export var retreat_distance: float = 50.0
## Retreat speed factor (0 = use agent's default speed factor).
@export var speed_factor: float = 0.0
## Speed the entity should rotate at.
@export var rotation_speed: float = 6.0
@export var rotation_away_from_target: bool = false
## Maximum retreat duration.
@export var duration: float = 0.0
## Use path finding for retreat.
@export var pathfinding: bool = false
## Force immediate updates.
@export var immediate_response: bool = false
## Path update frequency.
@export var path_update_interval: float = 0.05

var target: ChickenPlayer
var retreat_position: Vector3 = Vector3.ZERO

var _away_direction: Vector3 = Vector3.ZERO
var _last_path_update: float = 0.0
var _current_direction: Vector3 = Vector3.ZERO
var _last_target_position: Vector3 = Vector3.ZERO


func _generate_name() -> String:
	return "Retreat ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _enter() -> void:
	target = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return

	# Calculate retreat position away from target
	_away_direction = target.global_position.direction_to(agent.global_position)
	retreat_position = agent.global_position + _away_direction * retreat_distance

	if pathfinding:
		if not agent.nav.velocity_computed.is_connected(_on_velocity_computed):
			agent.nav.velocity_computed.connect(_on_velocity_computed, CONNECT_DEFERRED)
			var shape: Shape3D = agent.shape.shape
			if shape is CapsuleShape3D:
				agent.nav.radius = shape.radius
			elif shape is BoxShape3D:
				agent.nav.radius = shape.size.x / 2.0

		agent.nav.target_position = retreat_position


func _tick(delta: float) -> Status:
	if not is_instance_valid(target):
		return FAILURE

	var target_position: Vector3 = target.global_position
	var target_moved: bool = _last_target_position.distance_to(target_position) > 0.1

	# Recalculate retreat position if target moved significantly
	if target_moved:
		_away_direction = target.global_position.direction_to(agent.global_position)
		retreat_position = agent.global_position + _away_direction * retreat_distance

		if pathfinding:
			agent.nav.target_position = retreat_position

	_last_target_position = target_position

	if pathfinding:
		if immediate_response or target_moved or _last_path_update >= path_update_interval:
			agent.nav.target_position = retreat_position
			_last_path_update = 0.0
		else:
			_last_path_update += delta

	if _has_retreated():
		return SUCCESS

	if duration > 0 and elapsed_time > duration:
		return SUCCESS

	_move_away_from_target(delta, target_moved)
	return RUNNING


func _move_away_from_target(delta: float, target_moved: bool):
	var speed = speed_factor if speed_factor > 0.0 else agent.stats.calculate_speed(agent.movement_component.sprint_speed_factor)

	if pathfinding:
		_current_direction = (agent.nav.get_next_path_position() - agent.global_position).normalized()
		if immediate_response and target_moved:
			agent.velocity = _current_direction * speed
		agent.nav.set_velocity(_current_direction * speed)
	else:
		# Direct retreat movement
		_current_direction = target.global_position.direction_to(agent.global_position)
		agent.velocity = _current_direction * speed
	
	 # Rotate towards opposite direction (Disabled, because I want to moonwalk)
	if _current_direction.length() > 0 and rotation_away_from_target:
		var target_rotation: Basis = Basis.looking_at(_current_direction, Vector3.UP)
		agent.transform.basis = agent.transform.basis.slerp(target_rotation, rotation_speed * delta)


func _on_velocity_computed(safe_velocity: Vector3):
	if not (immediate_response and _last_target_position.distance_to(target.global_position) > 0.1):
		agent.velocity = safe_velocity


func _has_retreated() -> bool:
	return agent.global_position.distance_to(target.global_position) >= retreat_distance
