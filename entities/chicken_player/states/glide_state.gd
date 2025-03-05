extends BasePlayerState

@export var glide_gravity: float = 1.5
@export var glide_fall_speed: float = 2
@export var glide_speed: float = 15

func enter(_previous_state: PlayerEnums.PlayerStates) -> void:
	super.enter(_previous_state)
	movement_speed = glide_speed

func physics_process(delta: float) -> void:
	# Applying default player movement
	super(delta)
	
	# Apply modified gravity
	var gravity: float = player.get_gravity().y * glide_gravity
	player.velocity.y += gravity * delta
	
	# Clamp vertical speed
	player.velocity.y = min(player.velocity.y, glide_fall_speed)
	
	# Check for state transitions
	if player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE)
	
	
