extends BasePlayerMovementState

var _stamina_cost: int


func enter(prev_state: BasePlayerMovementState, _information: Dictionary = {}) -> void:
	super(prev_state)

	animation_tree.get("parameters/MovementStateMachine/playback").travel(self.name)

	_stamina_cost = movement_component.sprint_stamina_cost


func input(_event: InputEvent) -> void:
	# Handle state transitions
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE, {})

	if not player.is_on_floor():
		return

	if get_jump_velocity() > 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {"from_ground": true})
		return


func process(delta: float) -> void:
	# Drain stamina and updates the stamina bar in the HUD
	player.stats.drain_stamina(_stamina_cost * delta)

	# Handle state transitions
	if not is_sprinting() or player.stats.current_stamina <= 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})
		return

	if player.stats.current_health <= 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DEATH_STATE, {})
		return


func physics_process(delta: float) -> void:
	apply_gravity(delta)

	var velocity = get_player_direction() * player.stats.calculate_speed(movement_component.sprint_speed_factor)

	# Handle state transitions
	if not player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {"coyote_time": true})
		return

	if velocity == Vector3.ZERO:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		return

	apply_movement(velocity)
