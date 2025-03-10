## State handling player dash movement
## 
## Applies instant burst movement in facing direction with stamina cost
extends BasePlayerState

@export_range(10, 100) var stamina_cost: int = 30

@export_range(1.0, 20.0) var dash_distance: float = 30.0

var _dash_available: bool = true
var _dash_direction: Vector3

@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer


func enter(_previous_state: PlayerEnums.PlayerStates, information: Dictionary = {}) -> void:
	# check if already dashed
	if information.get("dashed", false):
		print("already dashed")
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, information)
		return

	if not _dash_available or player.stamina < stamina_cost:
		if previous_state == PlayerEnums.PlayerStates.JUMP_STATE:
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, information)
		else:
			SignalManager.player_transition_state.emit(_previous_state, information)
		return

	super.enter(_previous_state)

	# Consume stamina
	player.stamina -= stamina_cost

	# Get dash direction (player-relative input or player forward)
	var input_dir: Vector2 = get_player_input_dir()

	if input_dir != Vector2.ZERO:
		# Use movement direction from input (matches player-relative movement)
		_dash_direction = get_player_direction(input_dir)
	else:
		# Fallback to player's forward direction
		_dash_direction = player.global_basis.z.normalized()

	# Ensure vertical component is flat
	_dash_direction.y = 0

	# Initial velocity burst
	player.velocity = -_dash_direction * dash_distance

	dash_duration_timer.start()


func physics_process(_delta: float) -> void:
	player.velocity = -_dash_direction * dash_distance


func exit() -> void:
	_dash_available = false
	dash_cooldown_timer.start()


func _on_dash_timer_timeout():
	# Transition back to the previous state
	var information: Dictionary = {"dashed": true}
	if previous_state == PlayerEnums.PlayerStates.JUMP_STATE:
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, information)
	else:
		SignalManager.player_transition_state.emit(previous_state, information)


func _on_dash_cooldown_timer_timeout():
	print("dash available again")
	_dash_available = true
