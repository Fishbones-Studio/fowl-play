@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"
## Controls the height of the pounce.
@export_range(1.0, 100.0, 0.1) var jump_factor: float = 1.0
## Movement speed during the pounce sequence.
@export var horizontal_speed: float = 40.0
## Minimum distance to target before returning SUCCESS.
@export var min_distance: float = 10.0
## The maximun duration the pounce sequence should last
@export var duration: float = 1.0

var _is_jumping: bool = false
var _target_position: Vector3
var _initial_jump_velocity: Vector3


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

	if agent.is_on_floor() and agent.velocity.y < 0:
		_is_jumping = false
		return SUCCESS

	if elapsed_time > duration:
		_is_jumping = false
		return SUCCESS

	if agent.global_position.distance_to(_target_position) < min_distance:
		return SUCCESS

	return RUNNING
