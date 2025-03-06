extends BasePlayerState

@export var glide_hold_threshold: float = 0.25  # Seconds to hold for glide
@export var fall_movement_speed: float = 35

@onready var coyote_timer : Timer = $CoyoteTimer ## Timer to manage jump availability after leaving the ground, so the player can jump when just barely off the platform

var jump_available: bool = false
var dashed: bool = false
var is_jump_held: bool = false
var jump_press_time: float = 0.0

func enter(_previous_state: PlayerEnums.PlayerStates, information : Dictionary = {}) -> void:
	movement_speed = fall_movement_speed
	super.enter(_previous_state)
	
	# check for jump availability and dash in information
	jump_available = information.get("jump_available", false)
	dashed = information.get("dashed", false)
	
	
		
		# TODO fix double jump with coyote time
		
func process(_delta: float) -> void:
	# state transitions
	if  Input.is_action_pressed("jump") and not is_jump_held:
		jump_press_time = Time.get_ticks_msec()
		is_jump_held = true

	if is_jump_held:
		if Input.is_action_pressed("jump"):
			# Check if held longer than threshold
			if Time.get_ticks_msec() - jump_press_time > glide_hold_threshold * 1000:
				SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.GLIDE_STATE, {})
				is_jump_held = false
		elif jump_available:
			# Button released before threshold
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {})
			is_jump_held = false

	# check for landing
	if player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})

func physics_process(delta: float) -> void:
	# apply gravity
	player.velocity.y += player.get_gravity().y * delta

func exit() -> void:
	coyote_timer.stop()
	jump_available = false

func _on_coyote_timer_timeout():
	jump_available = false
