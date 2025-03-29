class_name BaseEnemyState
extends BaseState

#Instantiate globally used variables around the enemy states
@export var DELTA_MODIFIER: float = 100
@export var enemy: Enemy
@export var chase_distance: float = 20
@export var STATE_TYPE: EnemyEnums.EnemyStates
@export var ANIMATION_NAME: String

var player: ChickenPlayer
var previous_state: EnemyEnums.EnemyStates
var weapon: MeleeWeapon


func setup(_enemy: Enemy, _weapon: MeleeWeapon, _player: ChickenPlayer) -> void:
	if _enemy == null:
		push_error(owner.name + ": No enemy reference set" + str(STATE_TYPE))
	enemy = _enemy
	if _weapon == null:
		push_error(owner.name + ": No weapon reference set" + str(STATE_TYPE))
	weapon = _weapon
	if _player == null:
		push_error(owner.name + ": No player reference set" + str(STATE_TYPE))
	player = _player


func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	previous_state = _previous_state
