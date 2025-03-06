extends BasePlayerState

var knockback_force: Vector3
@export var KNOCKBACK_STRENGTH: float = 5.0
@export var VERTICAL_KNOCKBACK: float = 8.0

func enter(_previous_state: PlayerEnums.PlayerStates, _information : Dictionary = {}) -> void:
	# Calculate knockback direction 
	var knockback_direction: Vector3 = -player.transform.basis.z
	
	knockback_force = Vector3(
		knockback_direction.x * KNOCKBACK_STRENGTH,
		VERTICAL_KNOCKBACK,
		knockback_direction.z * KNOCKBACK_STRENGTH
	)

	# Apply initial knockback force
	player.velocity = knockback_force

func physics_process(delta: float) -> void:
	# Apply gravity
	player.velocity.y += player.get_gravity().y * delta

	# Check for landing
	if player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
