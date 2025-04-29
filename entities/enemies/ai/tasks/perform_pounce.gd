@tool
extends BTAction

@export var target_var: StringName = &"target"
@export var jump_velocity_factor: float = 1.8
@export var horizontal_speed: float = 40.0
@export var min_distance: float = 2.0

var _is_jumping: bool = false
var _target_position: Vector3


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

	var direction: Vector3 = (_target_position - agent.global_position).normalized()

	agent.velocity = Vector3(
		direction.x * horizontal_speed,
		agent.movement_component.get_jump_velocity() * jump_velocity_factor,
		direction.z * horizontal_speed
	)


func _tick(delta: float) -> Status:
	agent.apply_gravity(delta)

	if not _is_jumping:
		return FAILURE

	var to_target: Vector3 = (_target_position - agent.global_position)
	var horizontal_dir: Vector3 = Vector3(to_target.x, 0, to_target.z).normalized()

	agent.apply_movement(horizontal_dir * horizontal_speed)

	if agent.is_on_floor():
		_is_jumping = false
		return SUCCESS

	if agent.global_position.distance_to(_target_position) < min_distance:
		return SUCCESS

	return RUNNING
