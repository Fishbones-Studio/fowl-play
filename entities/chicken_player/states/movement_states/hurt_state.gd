## **NOTE** this file is work in progress and not all sections are complete
extends BasePlayerMovementState

@export var knockback_decay: int = 50 # Rate at which the knockback decays per second

var _knockback: Vector3
var _is_immobile: bool

@onready var hurt_timer: Timer = $HurtTimer


func enter(prev_state: BasePlayerMovementState, info: Dictionary = {}) -> void:
	super(prev_state)

	player.velocity.x = 0
	player.velocity.z = 0

	hurt_timer.start()
	_is_immobile = true

	if "knockback" in info:
		_knockback = info["knockback"]


func physics_process(delta: float) -> void:
	apply_gravity(delta)

	if _is_immobile:
		player.velocity += _knockback
		_knockback = _knockback.move_toward(Vector3.ZERO, knockback_decay * delta)

	if not _is_immobile:
		if not player.is_on_floor():
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {})
			return

		if get_player_direction() == Vector3.ZERO:
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
			return

		if is_sprinting():
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})
			return

		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})

	player.move_and_slide()


func _on_hurt_timer_timeout() -> void:
	_is_immobile = false
