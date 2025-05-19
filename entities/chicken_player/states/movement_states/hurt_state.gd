extends BasePlayerMovementState

@export var knockback_decay: int = 50 # Rate at which the knockback decays per second

var _knockback: Vector3
var _is_immobile: bool

@onready var immobile_timer: Timer = $ImmobileTimer
@onready var on_hurt: AudioStreamPlayer = $HurtSFX


func enter(prev_state: BasePlayerMovementState, info: Dictionary = {}) -> void:
	if player.stats.current_health <= 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DEATH_STATE, {})
		return

	super(prev_state)

	# Play hurt sound
	on_hurt.play()

	# Fire the OneShot request
	animation_tree.set("parameters/HurtOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	player.velocity.x = 0
	player.velocity.z = 0

	if "knockback" in info:
		_knockback = info["knockback"]

		# Set immobile time
		var immobile_time: float = _knockback.length() / knockback_decay
		if not is_equal_approx(immobile_time, 0):
			immobile_timer.wait_time = immobile_time
			immobile_timer.start()
			_is_immobile = true


func process(_delta: float) -> void:
	if player.stats.current_health <= 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DEATH_STATE, {})
		return


func physics_process(delta: float) -> void:
	apply_gravity(delta)

	if _is_immobile:
		player.velocity += _knockback
		_knockback = _knockback.move_toward(Vector3.ZERO, knockback_decay * delta)

	if not _is_immobile:
		if not player.is_on_floor():
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {
				"initial_velocity": player.velocity,
			})
			return

		if get_player_direction() == Vector3.ZERO:
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
			return

		if is_sprinting():
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})
			return

		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})

	player.move_and_slide()


func _on_immobile_timer_timeout() -> void:
	_is_immobile = false
