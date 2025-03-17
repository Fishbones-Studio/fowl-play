extends BasePlayerState

@export var air_movement_speed: float = 2.0
@export var jump_velocity: float = 15.0
@export var air_jumps: int = 2

var _air_jumps_used: int = 0


func enter(_previous_state: PlayerEnums.PlayerStates, information: Dictionary = {}) -> void:

	# checking if jump is available, otherwise go to falling state
	if !information.get("jump_available", true):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})
		return

	super.enter(_previous_state)

	movement_speed = air_movement_speed
	player.velocity.y = jump_velocity


func process(delta: float) -> void:
	player.regen_stamina(delta)
	# Handle air jump input
	if Input.is_action_just_pressed("jump") and _air_jumps_used < air_jumps:
		_air_jumps_used += 1
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
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {"jump_available": _air_jumps_used < air_jumps})

	# Check for landing
	if player.is_on_floor():
		_air_jumps_used = 0  # Reset air jumps when landing
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		return
		
