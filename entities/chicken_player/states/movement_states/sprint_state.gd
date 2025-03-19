extends BasePlayerMovementState

@export var sprint_speed: float = 60.0
@export var sprint_stamina_cost: int = 30


func enter(_previous_state: PlayerEnums.PlayerStates, _information: Dictionary = {}) -> void:
	# Check for stamina
	if player.stamina < sprint_stamina_cost:
		print("Not enough stamina to sprint")
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})
		return

	movement_speed = sprint_speed


func input(event: InputEvent) -> void:
	# Check for jump input
	if event.is_action_pressed("jump") and player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {})


func process(delta: float) -> void:
	# subtract stamina
	player.stamina -= sprint_stamina_cost * delta

	if not Input.is_action_pressed("sprint") or player.stamina <= 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})

	# Handle dash transition
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE, {})


func physics_process(delta: float) -> void:
	super(delta)

	# Check for state transitions
	if not player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {"coyote_time": true})
		return

	if player.velocity.x == 0 and player.velocity.z == 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
