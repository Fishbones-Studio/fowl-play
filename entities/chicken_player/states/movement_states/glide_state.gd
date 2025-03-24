extends BasePlayerMovementState

@export_range(0, 1, 0.01) var glide_gravity: float = 0.4
@export var glide_movement_speed: float = 25
@export var glide_stamina_cost: int = 35


func enter(_previous_state: PlayerEnums.PlayerStates, _information: Dictionary = {}) -> void:
	# set the y velocity to 0
	#player.velocity.y = 0

	# check for stamina
	if player.stamina < glide_stamina_cost:
		print("Not enough stamina to glide")
		SignalManager.player_transition_state.emit(_previous_state, _information)
		return

	movement_speed = glide_movement_speed
	super.enter(_previous_state)


func process(_delta: float) -> void:
	# subtract stamina
	player.stamina -= glide_stamina_cost * _delta

	# if stamina is less than 0, go to fall state
	if player.stamina <= (glide_stamina_cost *_delta):
		print("Not enough stamina to glide")
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})

	# check if the player is holding the jump button
	if Input.is_action_just_released("jump"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})


func physics_process(delta: float) -> void:
	# Applying default player movement
	super(delta)

	# Apply modified gravity
	var gravity: float = player.get_gravity().y * glide_gravity
	player.velocity.y += gravity * delta

	# Check for state transitions
	if player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})


func exit() -> void:
	# reset the gravity scale
	pass
