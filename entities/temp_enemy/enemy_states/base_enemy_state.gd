class_name BaseEnemyState
extends BaseState

#Instantiate globally used variables around the enemy states
@export var DELTA_MODIFIER: float = 100
@export var chase_distance: float = 100
#@export var attack_range : float = 10 <- to be implemented later with connection to specific weapon
@export var enemy: Enemy
@export var STATE_TYPE: EnemyEnums.EnemyStates

var previous_state: EnemyEnums.EnemyStates
var attack_range: Area3D

@onready var player = GameManager.chicken_player


func setup(_enemy: Enemy, _attack_range: Area3D) -> void:
	if _enemy == null:
		push_error(owner.name + ": No enemy reference set" + str(STATE_TYPE))
	enemy = _enemy
	if _attack_range == null:
		push_error(owner.name + ": No attack range reference set" + str(STATE_TYPE))
	attack_range = _attack_range


func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	previous_state = _previous_state
