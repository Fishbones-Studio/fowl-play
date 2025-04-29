@tool
extends BTAction

@export var jump_height: float

var _initial_jump_height: float


func _enter() -> void:
	if jump_height:
		_initial_jump_height = agent.movement_component.jump_height
		agent.movement_component.jump_height = jump_height

	agent.velocity.y = agent.movement_component.get_jump_velocity()


func _tick(delta: float) -> Status:
	if agent.velocity.y < 0:
		agent.movement_component.jump_height = _initial_jump_height
		return SUCCESS

	return RUNNING
