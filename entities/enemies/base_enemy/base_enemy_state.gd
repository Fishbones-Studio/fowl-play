class_name BaseEnemyState
extends BaseEnemyMovementState

# Instantiate globally used variables around the enemy states
@export var delta_modifier: float = 100
@export var chase_distance: float = 60
@export var state_type: EnemyEnums.EnemyStates

var player: ChickenPlayer
var previous_state: EnemyEnums.EnemyStates
var weapon: MeleeWeapon
var calculated_speed: float
var animation_tree: AnimationTree


func setup(_enemy: Enemy, _player: ChickenPlayer, _movement_component: EnemyMovementComponent, _animation_tree: AnimationTree) -> void:
	if _enemy == null:
		push_error(owner.name + ": No enemy reference set" + str(state_type))
	enemy = _enemy
	if _player == null:
		push_error(owner.name + ": No player reference set" + str(state_type))
	player = _player
	if _movement_component == null:
		push_error(owner.name + ": No movement component reference set" + str(state_type))
	movement_component = _movement_component
	if _animation_tree == null:
		push_error(owner.name + ": No animation tree reference set" + str(state_type))
	animation_tree = _animation_tree


func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	previous_state = _previous_state
