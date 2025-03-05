extends BasePlayerState

@export var walk_speed: float = 40.0

func enter(_previous_state: PlayerEnums.PlayerStates) -> void:
	movement_speed = walk_speed

func physics_process(delta: float) -> void:	
	super(delta)
	
	# Check for state transitions
	if not player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE)
		return

func input(event: InputEvent) -> void:
	# Check for jump input
	if event.is_action_pressed("jump") and player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE)
	
	# Check for dash input
	elif event.is_action_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE)

	elif Input.is_action_pressed("sprint") and player.stamina > 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.SPRINT_STATE)
