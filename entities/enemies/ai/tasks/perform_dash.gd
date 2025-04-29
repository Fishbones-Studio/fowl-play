@tool
extends BTAction

@export var target_var: StringName = &"target"
@export var dash_duration: float = 0.2
@export var min_distance: float = 3.0

var _dash_timer: float = 0.0
var _target_position: Vector3


func _generate_name() -> String:
	return "Dash ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _enter() -> void:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		push_warning("Dash: Target is not a valid ChickenPlayer (%s: %s)" % [
			LimboUtility.decorate_var(target_var), blackboard.get_var(target_var)])
		return

	_dash_timer = dash_duration
	_target_position = target.global_position


func _tick(delta: float) -> Status:
	agent.apply_gravity(delta)

	_dash_timer -= delta

	agent.velocity = -agent.global_basis.z * agent.stats.calculate_speed(agent.movement_component.dash_speed_factor)
	agent.move_and_slide()

	if agent.global_position.distance_to(_target_position) < min_distance or _dash_timer <= 0:
		return SUCCESS

	return RUNNING
