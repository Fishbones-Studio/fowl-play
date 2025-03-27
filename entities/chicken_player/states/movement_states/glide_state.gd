extends BasePlayerMovementState

var stamina_cost: int

func enter(previous_state: BasePlayerMovementState, information: Dictionary = {}) -> void:
	super(previous_state)
	
	stamina_cost = movement_component.glide_stamina_cost
	
	if player.stats.current_stamina < stamina_cost:
		print("Not enough stamina to glide")
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.FALL_STATE, {})
		return


func process(delta: float) -> void:
	SignalManager.stamina_changed.emit(player.stats.drain_stamina(stamina_cost * delta))
	
	if player.stats.current_stamina <= (stamina_cost * delta):
		print("Not enough stamina to glide")
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.FALL_STATE, {})
		return
	
	if Input.is_action_just_released("jump"):
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.FALL_STATE, {})


func physics_process(delta: float) -> void:
	player.velocity.y += get_gravity(player.velocity) * delta * movement_component.glide_speed_factor
	
	var speed_factor: float
	
	if Input.is_action_pressed("sprint"):
		speed_factor = movement_component.sprint_speed_factor * movement_component.glide_speed_factor
	else:
		speed_factor = movement_component.walk_speed_factor * movement_component.glide_speed_factor
	
	var velocity = get_player_direction() * player.stats.calculate_speed(speed_factor)
	
	player.velocity.x = velocity.x
	player.velocity.z = velocity.z
	player.move_and_slide()
	
	if player.is_on_floor():
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
