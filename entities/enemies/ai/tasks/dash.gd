@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"
## Duration of the dash.
@export var dash_duration: float = 0.2
## Minimun travel distance of the dash.
@export var dash_distance: float = 30.0

var _dash_timer: float = 0.0
var _dash_speed: float = 0.0
var _dash_direction: Vector3 = Vector3.ZERO


func _generate_name() -> String:
	return "Dash ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _enter() -> void:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return

	_dash_timer = dash_duration
	_dash_direction = -agent.global_basis.z.normalized()
	_dash_speed = (dash_distance / dash_duration) + agent.stats.calculate_speed(agent.movement_component.dash_speed_factor)


func _tick(delta: float) -> Status:
	_dash_timer -= delta

	agent.velocity = _dash_direction * _dash_speed

	if _dash_timer <= 0:
		return SUCCESS

	return RUNNING
