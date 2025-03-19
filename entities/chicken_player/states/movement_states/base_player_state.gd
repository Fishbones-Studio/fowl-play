class_name BasePlayerState
extends BaseState

@export var STATE_TYPE: PlayerEnums.PlayerStates
@export var DELTA_MODIFIER: float = 100 ## Used to modify when delta time is used, so movement speed does not need to be in the thousands

var player: ChickenPlayer
var movement_speed: float = 0.0
var previous_state: PlayerEnums.PlayerStates


## Called once to set the player reference
##
## Parameters:
## _player: The player reference to set.
func setup(_player: ChickenPlayer) -> void:
	if _player == null:
		push_error(owner.name + ": No player reference set" + str(STATE_TYPE))
	player = _player


## Called once when entering the state
##
## Parameters:
## _previous_state: The state that was active before this one.
func enter(_previous_state: PlayerEnums.PlayerStates, _information: Dictionary = {}) -> void:
	previous_state = _previous_state


# Providing default player movement
func physics_process(delta: float) -> void:
	if movement_speed == 0.0:
		push_error("BasePlayerState: movement_speed is null. Please set it in the child class before calling super.")

	var direction: Vector3 = get_player_direction( get_player_input_dir())

	# Apply horizontal movement
	player.velocity.x = direction.x * movement_speed * delta * DELTA_MODIFIER
	player.velocity.z = direction.z * movement_speed * delta * DELTA_MODIFIER


func get_player_input_dir() -> Vector2:
	# Get 3D movement input
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")


func get_player_direction(input_dir: Vector2) -> Vector3:
	# Calculate camera-relative movement direction
	var player_basis: Basis = player.global_basis
	return (player_basis.x * input_dir.x + player_basis.z * input_dir.y).normalized()
