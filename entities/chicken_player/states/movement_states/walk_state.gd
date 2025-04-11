extends BasePlayerMovementState

func enter(prev_state: BasePlayerMovementState, _info: Dictionary = {}) -> void:
	super(prev_state)


func input(_event: InputEvent) -> void:
	# Handle state transitions
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE, {})
		return

	if not player.is_on_floor():
		return

	if get_jump_velocity() > 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {"from_ground": true})
		return

	if Input.is_action_pressed("sprint") and player.stats.current_stamina > 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})


func process(delta: float) -> void:
	player.stats.regen_stamina(delta)

	if player.stats.current_health <= 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DEATH_STATE, {})
		return

func physics_process(delta: float) -> void:
	apply_gravity(delta)

	var velocity: Vector3 = get_player_direction() * player.stats.calculate_speed(movement_component.walk_speed_factor)

	# Handle state transitions
	if not player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {"coyote_time": true})
		return

	if velocity == Vector3.ZERO:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		return

	apply_movement(velocity)
