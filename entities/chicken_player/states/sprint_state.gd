extends BasePlayerState

@export var sprint_speed: float = 8.0
@export var sprint_stamina_cost: float = 0.5

func enter(_previous_state: PlayerEnums.PlayerStates) -> void:
	movement_speed = sprint_speed

func process(delta: float) -> void:
	# subtract stamina
	player.stamina -= sprint_stamina_cost * delta

	if not Input.is_action_pressed("sprint") or player.stamina <= 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE)

func physics_process(delta: float) -> void:
	super(delta)
	
	if player.velocity.x == 0 and player.velocity.z == 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE)
	
	

func input(event: InputEvent) -> void:
	# Check for jump input
	if event.is_action_pressed("jump") and player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE)
	
	# Check for dash input
	if event.is_action_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE)
