extends BasePlayerState

@export var movement_deadzone: float = 0.1 ## The minimum input value to consider switching over to movement. Gets added on top of deadzone from the input map.


func enter(_previous_state: PlayerEnums.PlayerStates, _information: Dictionary = {}) -> void:
	# check for horizontal movement, if so switch to walk state
	if player.velocity.x != 0 or player.velocity.z != 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})
		return


func input(event: InputEvent) -> void:
	# Check for jump input
	if event.is_action_pressed("jump") and player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {"coyote_time": true})


func process(delta: float) -> void:
	player.regen_stamina(delta)
	# Handle dash transition
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE, {})


func physics_process(_delta: float) -> void:
	# Check for state transitions
	if not player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	if input_dir.length() > movement_deadzone:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})
