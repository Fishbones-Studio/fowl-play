extends BasePlayerState

@export var air_movement_speed: float = 2.0
@export var jump_velocity: float = 20.0
@export var air_jumps: int = 2

var air_jumps_used: int = 0

func enter(_previous_state: PlayerEnums.PlayerStates) -> void:
	movement_speed = air_movement_speed
	player.velocity.y = jump_velocity

func physics_process(delta: float) -> void:
	super(delta)

	# Apply gravity first
	player.velocity.y += player.get_gravity().y * delta
	
	# transition to fall state
	if player.velocity.y < 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE)

	# Check for landing
	if player.is_on_floor():
		air_jumps_used = 0  # Reset air jumps when landing
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE)
		return

func input(event: InputEvent) -> void:
	#	# Handle air jumps
	if event.is_action_pressed("jump") && air_jumps_used < air_jumps:
		print("Air jump!")
		air_jumps_used += 1
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE)

	# Handle dash transition
	if event.is_action_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE)
		
