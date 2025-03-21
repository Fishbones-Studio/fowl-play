class_name BaseEnemyState
extends BaseState

@export var STATE_TYPE: EnemyEnums.EnemyStates
var previous_state: EnemyEnums.EnemyStates
@export var DELTA_MODIFIER: float = 100
var player := ChickenPlayer
@export var enemy: Enemy

func setup(_enemy: Enemy) -> void:
	if _enemy == null:
		push_error(owner.name + ": No enemy reference set" + str(STATE_TYPE))
	enemy = _enemy

func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	previous_state = _previous_state
