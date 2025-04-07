extends BasePlayerMovementState

var _stamina_cost: int


func enter(prev_state: BasePlayerMovementState, _information: Dictionary = {}) -> void:
	super(prev_state)

	player.velocity.y = 0

	_stamina_cost = movement_component.glide_stamina_cost

	# Handle state transitions
	if player.stats.current_stamina < _stamina_cost:
		print("Not enough stamina to glide")
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})
		return

	animation_tree.get("parameters/MovementStateMachine/playback").travel(self.name)


func process(delta: float) -> void:
	# Drain stamina and updates the stamina bar in the HUD
	if is_sprinting():
		player.stats.drain_stamina(movement_component.sprint_stamina_cost * delta)

	SignalManager.stamina_changed.emit(player.stats.drain_stamina(_stamina_cost * delta))

	# Handle state transitions
	if player.stats.current_stamina <= _stamina_cost * delta:
		print("Not enough stamina to glide")
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})
		return

	if Input.is_action_just_released("jump"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})


func physics_process(delta: float) -> void:
	player.velocity.y += get_gravity(player.velocity) * delta * movement_component.glide_speed_factor

	var speed_factor: float

	if is_sprinting():
		speed_factor = movement_component.sprint_speed_factor - movement_component.glide_speed_factor
	else:
		speed_factor = movement_component.walk_speed_factor - movement_component.glide_speed_factor

	var velocity: Vector3 = get_player_direction() * player.stats.calculate_speed(speed_factor)

	apply_movement(velocity)

	# Handle state transitions
	if player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
