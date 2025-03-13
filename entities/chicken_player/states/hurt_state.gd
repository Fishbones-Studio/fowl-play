## **NOTE** this file is work in progress and not all sections are complete

extends BasePlayerState

@export var knockback_strength: float = 5.0
@export var vertical_knockback: float = 8.0

var _knockback_force: Vector3


func enter(_previous_state: PlayerEnums.PlayerStates, _information: Dictionary = {}) -> void:
	# Calculate knockback direction 
	var knockback_direction: Vector3 = -player.transform.basis.z

	_knockback_force = Vector3(
		knockback_direction.x * knockback_strength,
		vertical_knockback,
		knockback_direction.z * knockback_strength
	)

	# Apply initial knockback force
	player.velocity = _knockback_force


func physics_process(delta: float) -> void:
	# Apply gravity
	player.velocity.y += player.get_gravity().y * delta

	# Check for landing
	if player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
