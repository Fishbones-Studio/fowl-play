extends BasePlayerState

@onready var coyote_timer : Timer = $CoyoteTimer ## Timer to manage jump availability after leaving the ground, so the player can jump when just barely off the platform

var jump_available: bool = false
var dashed: bool = false

func enter(_previous_state: PlayerEnums.PlayerStates) -> void:
	super.enter(_previous_state)
	
	if (previous_state == PlayerEnums.PlayerStates.WALK_STATE or previous_state == PlayerEnums.PlayerStates.SPRINT_STATE):
		jump_available = true
		coyote_timer.start()
	elif previous_state == PlayerEnums.PlayerStates.DASH_STATE:
		dashed = true
	else:
		dashed = false
		
func process(_delta: float) -> void:
	# state transitions
	if Input.is_action_pressed("jump"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.GLIDE_STATE)
	elif jump_available and Input.is_action_just_pressed("jump"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE)
	elif not dashed and Input.is_action_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE)

	# check for landing
	if player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE)

func physics_process(delta: float) -> void:
	# apply gravity
	player.velocity.y += player.get_gravity().y * delta

func exit() -> void:
	coyote_timer.stop()
	jump_available = false

func _on_coyote_timer_timeout():
	jump_available = false
