extends BasePlayerMovementState

var shown: bool = false


func enter(prev_state: BasePlayerMovementState, information: Dictionary = {}) -> void:
	super(prev_state)

	#animation_tree.get("parameters/MovementStateMachine/playback").travel(self.name)

	if "initial_velocity" in information:
		player.velocity = information["initial_velocity"]
	else:
		player.velocity.x = 0
		player.velocity.z = 0


func physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if player.is_on_floor() && not shown:
		shown = true
		SignalManager.switch_ui_scene.emit(UIEnums.UI.DEATH_SCREEN)
	
	apply_movement(player.velocity)
