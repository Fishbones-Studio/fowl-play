extends BasePlayerMovementState


func enter(prev_state: BasePlayerMovementState, information: Dictionary = {}) -> void:
	super(prev_state)

	#animation_tree.get("parameters/MovementStateMachine/playback").travel(self.name)

	if "initial_velocity" in information:
		player.velocity = information["initial_velocity"]
	else:
		player.velocity.x = 0
		player.velocity.z = 0

	SignalManager.switch_ui_scene.emit(UIEnums.UI.DEATH_SCREEN)


func physics_process(delta: float) -> void:
	apply_gravity(delta)

	apply_movement(player.velocity)
