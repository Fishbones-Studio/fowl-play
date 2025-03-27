extends BasePlayerMovementState


func enter(previous_state: BasePlayerMovementState, _info: Dictionary = {}) -> void:
	super(previous_state)


func input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.DASH_STATE, {})
		return
	
	if not player.is_on_floor():
		return
	
	if get_jump_velocity() > 0:
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.JUMP_STATE, {"from_ground": true})
		return
	
	if Input.is_action_pressed("sprint") and player.stats.stamina > 0:
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})


func process(delta: float) -> void:
	SignalManager.stamina_changed.emit(player.stats.regen_stamina(delta))


func physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if not player.is_on_floor():
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.FALL_STATE, {"coyote_time": true})
		return
	
	var velocity = get_player_direction() * player.stats.calculate_speed(movement_component.walk_speed_factor)
	
	if velocity == Vector3.ZERO:
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		return
	
	player.velocity.x = velocity.x
	player.velocity.z = velocity.z
	player.move_and_slide()
