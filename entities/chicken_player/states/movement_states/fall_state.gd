extends BasePlayerMovementState

@export var glide_hold_threshold: float = 0.25  # Seconds to hold for glide
@export var fall_movement_speed: float = 35

var _jump_available: bool   = false
var _dashed: bool           = false
var _is_jump_held: bool     = false
var _jump_press_time: float = 0.0

@onready var coyote_timer: Timer = $CoyoteTimer ## Timer to manage jump availability after leaving the ground, so the player can jump when just barely off the platform


func enter(_previous_state: PlayerEnums.PlayerStates, information: Dictionary = {}) -> void:
	movement_speed = fall_movement_speed
	super.enter(_previous_state)

	# check for jump availability and dash in information
	_jump_available = information.get("jump_available", false)
	_dashed = information.get("dashed", false)
	var active_coyote_time = information.get("coyote_time", false)
	if active_coyote_time:
		coyote_timer.start(active_coyote_time)
		_jump_available = true


func process(delta: float) -> void:
	# apply movement
	player.regen_stamina(delta)
	# state transitions
	if  Input.is_action_pressed("jump") and not _is_jump_held:
		_jump_press_time = Time.get_ticks_msec()
		_is_jump_held = true

	if _is_jump_held:
		if Input.is_action_pressed("jump"):
			# Check if held longer than threshold
			if Time.get_ticks_msec() - _jump_press_time > glide_hold_threshold * 1000:
				SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.GLIDE_STATE, {})
				_is_jump_held = false
		elif _jump_available:
			print("Air jump")
			# Button released before threshold
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {})
			_is_jump_held = false

	# check for landing
	if player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})


func physics_process(delta: float) -> void:
	# apply gravity
	player.velocity.y += player.get_gravity().y * delta


func exit() -> void:
	coyote_timer.stop()
	_jump_available = false


func _on_coyote_timer_timeout():
	print("coyote timer expired")
	_jump_available = false
