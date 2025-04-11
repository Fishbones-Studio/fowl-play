class_name BaseEnemyState
extends BaseEnemyMovementState

#Instantiate globally used variables around the enemy states
@export var DELTA_MODIFIER: float = 100

@export var chase_distance: float = 20
@export var STATE_TYPE: EnemyEnums.EnemyStates
@export var ANIMATION_NAME: String

var player: ChickenPlayer
var previous_state: EnemyEnums.EnemyStates
var weapon: MeleeWeapon

func setup(_enemy: Enemy, _player: ChickenPlayer, _movement_component: EnemyMovementComponent) -> void:
	if _enemy == null:
		push_error(owner.name + ": No enemy reference set" + str(STATE_TYPE))
	enemy = _enemy
	if _player == null:
		push_error(owner.name + ": No player reference set" + str(STATE_TYPE))
	player = _player
	if _movement_component == null:
		push_error(owner.name + ": No movement component reference set" + str(STATE_TYPE))
	movement_component = _movement_component


func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	previous_state = _previous_state
