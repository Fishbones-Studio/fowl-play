@tool
extends BTAction

@export_range(1.0, 500.0, 0.1) var jump_factor: float = 1.0
## Duration of the jump.
@export var duration: float
## Oly return SUCCESS if enemy is on floor.
@export var grounded: bool = false

var _initial_jump_height: float
var movement_component: EnemyMovementComponent


func _generate_name() -> String:
	var name: String = "Jump ➜ "

	if not is_equal_approx(jump_factor, 1.0):
		name += "factor: %.1f  " % jump_factor

	if duration > 0:
		name += "duration: %.1fs  " % duration

	if grounded:
		name += "grounded: %s" % grounded

	return name if name != "Jump ➜ " else "Jump"


func _enter() -> void:
	movement_component = agent.movement_component

	if jump_factor > 1.0:
		_initial_jump_height = movement_component.jump_height
		movement_component.jump_height *= jump_factor

	agent.velocity.y = agent.movement_component.get_jump_velocity()


func _tick(delta: float) -> Status:
	if agent.velocity.y < 0 and not bool(duration) and not grounded:
		movement_component.jump_height = _initial_jump_height
		return SUCCESS

	if agent.is_on_floor() and grounded:
		movement_component.jump_height = _initial_jump_height
		return SUCCESS

	if bool(duration) and elapsed_time > duration:
		movement_component.jump_height = _initial_jump_height
		return SUCCESS

	return RUNNING
