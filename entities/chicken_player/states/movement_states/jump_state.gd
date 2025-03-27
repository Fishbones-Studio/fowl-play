extends BasePlayerMovementState

@export var air_jumps: int = 1

var _air_jumps_used: int = 0


func enter(previous_state: BasePlayerMovementState, information: Dictionary = {}) -> void:
	super(previous_state)
	
	if information.get("from_ground", false):
		_air_jumps_used = 0 # Reset air jumps if coming from the ground
	else:
		_air_jumps_used += 1 # Else increment air jumps used
	
	movement_component.jump_available = air_jumps > _air_jumps_used
	
	player.velocity.y = get_jump_velocity()


func input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.DASH_STATE, {})
		return
	
	if get_jump_velocity() > 0 and _air_jumps_used < air_jumps:
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.JUMP_STATE, {})


func process(delta: float) -> void:
	if is_sprinting():
		player.stats.drain_stamina(movement_component.sprint_stamina_cost * delta)
	else:
		player.stats.regen_stamina(delta)
	
	SignalManager.stamina_changed.emit(player.stats.current_stamina)


func physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if player.velocity.y < 0:
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.FALL_STATE, {})
		return
	
	var speed_factor: float
	
	if Input.is_action_pressed("sprint"):
		speed_factor = movement_component.sprint_speed_factor
	else:
		speed_factor = movement_component.walk_speed_factor
	
	var velocity = get_player_direction() * player.stats.calculate_speed(speed_factor)
	
	player.velocity.x = velocity.x
	player.velocity.z = velocity.z
	player.move_and_slide()
	
	if not player.is_on_floor():
		return
	
	if velocity == Vector3.ZERO:
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		return
	if Input.is_action_pressed("sprint"):
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})
		return
	
	SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.WALK_STATE, {})
