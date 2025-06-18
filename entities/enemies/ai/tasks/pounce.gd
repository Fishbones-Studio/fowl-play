@tool
extends BTAction

@export var target_var: StringName = &"target"
@export_range(1.0, 100.0, 0.1) var jump_factor: float = 1.0
@export var horizontal_speed: float = 40.0
@export var min_distance: float = 10.0
@export var duration: float = 2.0

var _is_jumping: bool = false
var _target_position: Vector3
var _initial_jump_velocity: Vector3
var _was_airborne: bool = false


func _generate_name() -> String:
	return "Pounce ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _enter() -> void:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)

	if not is_instance_valid(target):
		push_warning("Pounce: Target is not a valid ChickenPlayer (%s: %s)" % [
			LimboUtility.decorate_var(target_var), blackboard.get_var(target_var)])
		return

	_is_jumping = true
	_target_position = target.global_position
	_was_airborne = false

	var jump_height: float = agent.movement_component.get_jump_velocity()
	var direction: Vector3 = (_target_position - agent.global_position).normalized()

	_initial_jump_velocity = Vector3(
		direction.x * horizontal_speed,
		jump_height * jump_factor,
		direction.z * horizontal_speed
	)

	agent.velocity = _initial_jump_velocity


func _tick(delta: float) -> Status:
	if not _is_jumping:
		return FAILURE

	var to_target: Vector3 = (_target_position - agent.global_position)
	var horizontal_dir: Vector3 = Vector3(to_target.x, 0, to_target.z).normalized()

	agent.velocity.x += (horizontal_dir.x * horizontal_speed - agent.velocity.x) * delta
	agent.velocity.z += (horizontal_dir.z * horizontal_speed - agent.velocity.z) * delta

	# Track if the agent has left the ground
	if not _was_airborne and not agent.is_on_floor():
		_was_airborne = true

	# Only succeed if the agent has been airborne and is now on the floor
	if _was_airborne and agent.is_on_floor():
		return SUCCESS

	if is_equal_approx(agent.velocity.y, 0.0):
		return SUCCESS

	if agent.global_position.distance_to(_target_position) < min_distance:
		return SUCCESS

	if elapsed_time >= duration:
		return SUCCESS

	return RUNNING


func _exit() -> void:
	_is_jumping = false
