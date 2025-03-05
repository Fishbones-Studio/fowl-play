extends BasePlayerState

@export var movement_deadzone: float = 0.1

func enter(_previous_state : PlayerEnums.PlayerStates) -> void:
	# Stop horizontal movement
	player.velocity.x = 0
	player.velocity.z = 0

func physics_process(_delta: float) -> void:
	# Check for state transitions
	if not player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE)
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input_dir.length() > movement_deadzone:  
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE)


func input(event: InputEvent) -> void:
	# Check for jump input
	if event.is_action_pressed("jump") and player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE)
	elif event.is_action_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE)
