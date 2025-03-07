extends BasePlayerState

@export_range(0, 1, 0.01) var glide_gravity: float = 0.4
@export var glide_fall_speed: float = 1.5
@export var glide_movement_speed: float = 25

func enter(_previous_state: PlayerEnums.PlayerStates, _information : Dictionary = {}) -> void:
	movement_speed = glide_movement_speed
	super.enter(_previous_state)
	
func process(_delta: float) -> void:
	# check if the player is holding the jump button
	if Input.is_action_just_released("jump"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})

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
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		
