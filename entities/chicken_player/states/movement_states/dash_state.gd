################################################################################
## State handling player dash movement.
## 
## Applies instant burst movement in facing direction with stamina cost.
################################################################################
extends BasePlayerMovementState

var _stamina_cost: int
var _is_dashing: bool = false
var _dash_direction: Vector3

@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var dash_sfx: AudioStreamPlayer3D = %ChickenMovementPlayer


func enter(prev_state: BasePlayerMovementState, information: Dictionary = {}) -> void:
	_stamina_cost = movement_component.dash_stamina_cost

	# Handle state transitions
	if not movement_component.dash_available or player.stats.current_stamina < _stamina_cost:
		print("Dash available: ", movement_component.dash_available)
		if prev_state:
			SignalManager.player_transition_state.emit(prev_state.state_type, information)
		else:
			# Fallback to Idle state
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, information)
		return

	super(prev_state)
	player.stats.drain_stamina(_stamina_cost)

	movement_component.dash_available = false
	_is_dashing = true

	_dash_direction = get_player_direction()

	if _dash_direction == Vector3.ZERO:
		_dash_direction = -player.global_basis.z # Default forward direction

	# Fire the OneShot request
	animation_tree.set("parameters/DashOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	# Play sound only if dash is actually performed
	if dash_sfx:
		dash_sfx.play()

	dash_duration_timer.start()
	dash_cooldown_timer.start()



func physics_process(delta: float) -> void:
	apply_gravity(delta)

	if _is_dashing:
		player.velocity = _dash_direction * player.stats.calculate_speed(movement_component.dash_speed_factor)
		player.move_and_slide()
		return

	# Handle state transitions
	if get_jump_velocity() > 0 and movement_component.jump_available:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {})

	if not player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})
		return

	var direction: Vector3 = get_player_direction()

	if direction == Vector3.ZERO:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
		return

	if is_sprinting() and player.stats.current_stamina > 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})
		return

	SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})

	player.move_and_slide()


func _on_dash_duration_timer_timeout() -> void:
	_is_dashing = false


func _on_dash_cooldown_timer_timeout() -> void:
	print("Dash available: ", movement_component.dash_available)
	movement_component.dash_available = true
