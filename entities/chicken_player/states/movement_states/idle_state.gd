extends BasePlayerMovementState


func enter(previous_state: BasePlayerMovementState, _information: Dictionary = {}) -> void:
	super(previous_state)
	
	player.velocity.x = 0
	player.velocity.z = 0


func input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.DASH_STATE, {})
		return
	
	if not player.is_on_floor():
		return
	
	if get_jump_velocity() > 0:
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.JUMP_STATE, {"from_ground": true})
		return
	
	if get_player_direction() == Vector3.ZERO:
		return
		
	if Input.is_action_just_pressed("sprint"):
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})
		return
	
	SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.WALK_STATE, {})


func process(delta: float) -> void:
	SignalManager.stamina_changed.emit(player.stats.regen_stamina(delta))


func physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if not player.is_on_floor():
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.FALL_STATE, {"coyote_time": true})
		return
	
	player.move_and_slide()
