extends BasePlayerState

@export var air_movement_speed: float = 2.0
@export var jump_velocity: float = 15.0
@export var air_jumps: int = 2

var air_jumps_used: int = 0

func enter(_previous_state: PlayerEnums.PlayerStates, _information : Dictionary = {}) -> void:
	movement_speed = air_movement_speed
	player.velocity.y = jump_velocity
	
func process(_delta: float) -> void:
	# Handle air jump input
	if Input.is_action_just_pressed("jump") and air_jumps_used < air_jumps:
		air_jumps_used += 1
		player.velocity.y = jump_velocity

	# Handle dash transition
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE, {})

func physics_process(delta: float) -> void:
	super(delta)

	# Apply gravity first
	player.velocity.y += player.get_gravity().y * delta
	
	# transition to fall state
	if player.velocity.y < 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {"jump_available" : air_jumps_used < air_jumps})

	# Check for landing
	if player.is_on_floor():
		air_jumps_used = 0  # Reset air jumps when landing
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		return
		