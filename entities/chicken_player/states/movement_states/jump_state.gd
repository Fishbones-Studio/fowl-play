extends BasePlayerMovementState

@export var air_movement_speed: float = 20.0
@export var jump_velocity: float = 10.0
@export var air_jumps: int = 1
@export var air_movement_damping: float = 0.96

var _air_jumps_used: int = 0


func enter(_previous_state: PlayerEnums.PlayerStates, information: Dictionary = {}) -> void:
	if information.get("from_ground", false):
		# Reset air jumps if coming from the ground
		_air_jumps_used = 0
	else:
		# Increment air jumps used if not coming from the ground
		_air_jumps_used += 1  # Increment air jumps used

	# checking if jump is available, otherwise go to falling state
	if !information.get("jump_available", true):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {"jump_available": _air_jumps_used < air_jumps})
		return

	super.enter(_previous_state)

	movement_speed = air_movement_speed
	player.velocity.y = jump_velocity # Initial jump velocity


func process(delta: float) -> void:
	player.regen_stamina(delta)

	# Handle dash transition
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE, {"jump_available": _air_jumps_used < air_jumps})


func physics_process(delta: float) -> void:

	# Applying air movement
	var input_dir: Vector2 = get_player_input_dir()

	# applying air movement even after not pressing buttons anymore, but slowing down
	if input_dir == Vector2.ZERO && previous_state != PlayerEnums.PlayerStates.IDLE_STATE:
		player.velocity.x *= air_movement_damping
		player.velocity.z *= air_movement_damping
	else:
		super(delta)

	# Apply gravity first
	player.velocity.y += player.get_gravity().y * delta

	# transition to fall state
	if player.velocity.y < 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {"jump_available": _air_jumps_used < air_jumps})
		
		
