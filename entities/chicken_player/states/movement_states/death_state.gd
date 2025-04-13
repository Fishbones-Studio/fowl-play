extends BasePlayerMovementState


func enter(prev_state: BasePlayerMovementState, information: Dictionary = {}) -> void:
	super(prev_state)

	if "initial_velocity" in information:
		player.velocity = information["initial_velocity"]
	else:
		player.velocity.x = 0
		player.velocity.z = 0


func physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if player.is_on_floor():
		SignalManager.switch_ui_scene.emit("uid://ba8j8ajmddtai")
	
	apply_movement(player.velocity)
