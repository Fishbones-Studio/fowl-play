extends BasePlayerMovementState

var _stamina_cost: int


func enter(previous_state: BasePlayerMovementState, _information: Dictionary = {}) -> void:
	super(previous_state)
	
	_stamina_cost = movement_component.sprint_stamina_cost


func input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.DASH_STATE, {})
	
	if not player.is_on_floor():
		return
	
	if get_jump_velocity() > 0:
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.JUMP_STATE, {"from_ground": true})
		return


func process(delta: float) -> void:
	SignalManager.stamina_changed.emit(player.stats.drain_stamina(_stamina_cost * delta))
	
	if not Input.is_action_pressed("sprint") or player.stats.current_stamina <= 0:
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.WALK_STATE, {})


func physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if not player.is_on_floor():
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.FALL_STATE, {"coyote_time": true})
		return
	
	var velocity = get_player_direction() * player.stats.calculate_speed(movement_component.sprint_speed_factor)
	
	if velocity == Vector3.ZERO:
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		return
	
	player.velocity.x = velocity.x
	player.velocity.z = velocity.z
	player.move_and_slide()
