extends BasePlayerMovementState

# Time for to hold for glide (in seconds)
@export var glide_hold_threshold: float = 0.1

var _jump_press_time: float = 0.0
var _is_jump_held: bool = false
var _has_coyote: bool = false

var _has_initial_velocity: bool

# Timer to manage jump availability after leaving the ground, so the 
# player can jump when just barely off the platform.
@onready var coyote_timer: Timer = $CoyoteTimer


func enter(prev_state: BasePlayerMovementState, information: Dictionary = {}) -> void:
	super(prev_state)

	var active_coyote_time = information.get("coyote_time", false)

	_has_initial_velocity = false

# So the player keeps the X/Z velocity. If not, the player abruptly stops midair.
# Then falls down. Which IS what we want after dashing, but not with other movement.
	if "initial_velocity" in information:
		player.velocity = information["initial_velocity"]
		_has_initial_velocity = true

	if active_coyote_time:
		_has_coyote = true
		coyote_timer.start(active_coyote_time)


func process(delta: float) -> void:
	if player.stats.current_health <= 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DEATH_STATE, {
			"initial_velocity": player.velocity,
		})
		return
	
	# Drain stamina if player is sprinting, else regenerate stamina
	if is_sprinting():
		player.stats.drain_stamina(movement_component.sprint_stamina_cost * delta)
	else:
		player.stats.regen_stamina(delta)

	# Handle state transitions
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE, {})
		return

	if  Input.is_action_pressed("jump") and not _is_jump_held:
		_jump_press_time = Time.get_ticks_msec()
		_is_jump_held = true

	if Input.is_action_pressed("jump") and _is_jump_held:
		var current_time: int = Time.get_ticks_msec()
		var hold_duration: float = current_time - _jump_press_time

		if hold_duration > glide_hold_threshold * 1000:
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.GLIDE_STATE, {})
			_is_jump_held = false
			return

		if movement_component.jump_available:
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {})
			_is_jump_held = false


func physics_process(delta: float) -> void:
	apply_gravity(delta)

	var speed_factor: float

	if is_sprinting():
		speed_factor = movement_component.sprint_speed_factor
	else:
		speed_factor = movement_component.walk_speed_factor

	var velocity: Vector3

	if _has_initial_velocity:
		velocity = player.velocity
	else:
		velocity = get_player_direction() * player.stats.calculate_speed(speed_factor)

	apply_movement(velocity)

	# Handle state transitions
	if not player.is_on_floor():
		return

	if velocity == Vector3.ZERO:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		return

	if Input.is_action_pressed("sprint"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})
		return

	SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})


func _on_coyote_timer_timeout():
	print("coyote timer expired")
	_has_coyote = false
