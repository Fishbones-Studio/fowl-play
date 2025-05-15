@tool
extends BTAction

@export_range(1.0, 100.0, 0.1) var jump_factor: float = 1.0
## Duration of the jump.
@export var duration: float
## Only return SUCCESS if enemy is falling.
@export var is_falling: bool = false
## Only return SUCCESS if enemy is on floor.
@export var has_landed: bool = true
## Only return SUCCESS if enemy reached jump peak.
@export var reached_peak: bool = false

var _movement_component: EnemyMovementComponent
var _initial_jump_height: float


func _generate_name() -> String:
	var name: String = "Jump ➜ "

	if not is_equal_approx(jump_factor, 1.0):
		name += "factor: %.1f  " % jump_factor

	if duration > 0:
		name += "duration: %.1fs  " % duration

	if is_falling:
		name += "is_falling: %s  " % is_falling

	if has_landed:
		name += "has_landed: %s  " % has_landed

	if reached_peak:
		name += "reached_peak: %s" % reached_peak

	return name if name != "Jump ➜ " else "Jump"


func _enter() -> void:
	_movement_component = agent.movement_component
	_initial_jump_height = _movement_component.jump_height

	if jump_factor > 1.0:
		_movement_component.jump_height *= jump_factor

	agent.velocity.y = _movement_component.get_jump_velocity()


func _tick(_delta: float) -> Status:
	if agent.velocity.y < 0 and is_falling:
		_reset_jump()
		return SUCCESS

	if agent.is_on_floor() and has_landed:
		_reset_jump()
		return SUCCESS

	if is_equal_approx(agent.velocity.y, 0.0) and reached_peak:
		_reset_jump()
		return SUCCESS

	if bool(duration) and elapsed_time > duration:
		_reset_jump()
		return SUCCESS

	return RUNNING


func _reset_jump() -> void:
	_movement_component.jump_height = _initial_jump_height
