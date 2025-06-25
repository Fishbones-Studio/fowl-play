extends BasePlayerMovementState

@export_group("Idle Audio")
@export var idle_sound : AudioStream
@export var idle_sound_player : AudioStreamPlayer3D
@export var idle_sound_min_interval: float = 10.0
@export var idle_sound_max_interval: float = 20.0

var _idle_sound_timer: float = 0.0
var _idle_sound_next_interval: float = 0.0

func enter(prev_state: BasePlayerMovementState, _information: Dictionary = {}) -> void:
	super(prev_state)
	animation_tree.get("parameters/MovementStateMachine/playback").travel(self.name)
	player.velocity.x = 0
	player.velocity.z = 0

	# Initialize idle sound timer and next interval
	_idle_sound_timer = 0.0
	_idle_sound_next_interval = randf_range(idle_sound_min_interval, idle_sound_max_interval)

func input(_event: InputEvent) -> void:
	# Handle state transitions
	if Input.is_action_just_pressed("dash"):
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.DASH_STATE, {})
		return

	if not player.is_on_floor():
		return

	if get_jump_velocity() > 0:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.JUMP_STATE, {"from_ground": true})
		return

	if get_player_direction() == Vector3.ZERO:
		return

	if is_sprinting():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})
		return

	SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.WALK_STATE, {})

func process(delta: float) -> void:
	# Regenerates stamina and updates the stamina bar in the HUD
	player.stats.regen_stamina(delta)

	# Idle sound logic
	_idle_sound_timer += delta
	if _idle_sound_timer >= _idle_sound_next_interval:
		if idle_sound_player and idle_sound:
			idle_sound_player.stream = idle_sound
			idle_sound_player.play()
		_idle_sound_timer = 0.0
		_idle_sound_next_interval = randf_range(idle_sound_min_interval, idle_sound_max_interval)

func physics_process(delta: float) -> void:
	apply_gravity(delta)

	# Handle state transitions
	if not player.is_on_floor():
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, {"coyote_time": true})
		return

	player.move_and_slide()

func exit() -> void:
	if idle_sound_player:
		idle_sound_player.stop()
	super()
