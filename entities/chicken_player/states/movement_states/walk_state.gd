extends BasePlayerMovementState

@export var walk_speed: float = 20.0


func enter(_previous_state: PlayerEnums.PlayerStates, _information: Dictionary = {}) -> void:
	movement_speed = walk_speed


func input(event: InputEvent) -> void:
	# Check for jump input
	if event.is_action_pressed("jump") and player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {})

	elif Input.is_action_pressed("sprint") and player.stamina > 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})


func process(delta: float) -> void:
	player.regen_stamina(delta)
	# Handle dash transition
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE, {})


func physics_process(delta: float) -> void:
	super(delta)

	# Check for state transitions
	if not player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {"coyote_time": true})
		return

	# Check for idle state
	if player.velocity.x == 0 and player.velocity.z == 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		
