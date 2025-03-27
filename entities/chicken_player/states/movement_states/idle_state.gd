extends BasePlayerMovementState


func enter(prev_state: BasePlayerMovementState, _information: Dictionary = {}) -> void:
	super(prev_state)
	
	player.velocity.x = 0
	player.velocity.z = 0


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
	
	if get_player_direction() == Vector3.ZERO:
		return
		
	if is_sprinting():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})
		return
	
	SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})


func process(delta: float) -> void:
	# Regenerates stamina and updates the stamina bar in the HUD
	SignalManager.stamina_changed.emit(player.stats.regen_stamina(delta))


func physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	# Handle state transitions
	if not player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {"coyote_time": true})
		return
	
	player.move_and_slide()
