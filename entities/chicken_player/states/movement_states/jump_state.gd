extends BasePlayerMovementState

@export var air_jumps: int = 1
@export var jump_buffer_time: float = 0.15  # Time before allowing next jump

var _air_jumps_used: int = 0
var _jump_timer: float = 0.0

func enter(prev_state: BasePlayerMovementState, information: Dictionary = {}) -> void:
	super(prev_state)

	if information.get("from_ground", false):
		_air_jumps_used = 0 # Reset air jumps if coming from the ground
	else:
		_air_jumps_used += 1 # Else increment air jumps used

	movement_component.jump_available = air_jumps > _air_jumps_used
	_jump_timer = 0.0  # Reset timer on state enter

	animation_tree.get("parameters/MovementStateMachine/playback").travel(self.name)

	player.velocity.y = get_jump_velocity()


func input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("dash") && movement_component.dash_available:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE, {})
		return
	
	# Allow double jump if enough time has passed and air jumps are available
	if Input.is_action_just_pressed("jump") and _jump_timer >= jump_buffer_time and _air_jumps_used < air_jumps:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {})


func process(delta: float) -> void:
	_jump_timer += delta  # Increment timer
	
	if is_sprinting():
		player.stats.drain_stamina(movement_component.sprint_stamina_cost * delta)
	else:
		player.stats.regen_stamina(delta)


func physics_process(delta: float) -> void:
	apply_gravity(delta)

	if player.velocity.y < 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})
		return

	var speed_factor: float

	if is_sprinting():
		speed_factor = movement_component.sprint_speed_factor
	else:
		speed_factor = movement_component.walk_speed_factor

	var velocity: Vector3 = get_player_direction() * player.stats.calculate_speed(speed_factor)

	apply_movement(velocity)

	if not player.is_on_floor():
		return

	if velocity == Vector3.ZERO:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		return
	if is_sprinting():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})
		return

	SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})
