extends BasePlayerMovementState

@onready var timer: Timer = $Timer


func enter(prev_state: BasePlayerMovementState, information: Dictionary = {}) -> void:
	super(prev_state)

	animation_tree.get("parameters/MovementStateMachine/playback").travel(self.name)

	UIManager.game_input_blocked = true

	if "initial_velocity" in information:
		player.velocity = information["initial_velocity"]
	else:
		player.velocity.x = 0
		player.velocity.z = 0

	timer.start()


func physics_process(delta: float) -> void:
	apply_gravity(delta)

	apply_movement(player.velocity)


# Using timer since for some reason AnimationNodeStateMachinePlayback never
# stops playing, and it also transitions immediately when comparing anim length.
func _on_timer_timeout() -> void:
	UIManager.game_input_blocked = false
	SignalManager.switch_ui_scene.emit(UIEnums.UI.DEATH_SCREEN)
