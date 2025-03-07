## State handling player dash movement
## 
## Applies instant burst movement in facing direction with stamina cost
extends BasePlayerState

@export_range(10, 100) var stamina_cost: int = 30

@export_range(1.0, 20.0) var dash_distance: float = 30.0

@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer

var dash_available: bool = true
var dash_direction: Vector3


func enter(_previous_state: PlayerEnums.PlayerStates, information: Dictionary = {}) -> void:
	# check if already dashed
	if information.get("dashed", false):
		print("already dashed")
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.IDLE_STATE, information)
		return

	if not dash_available or player.stamina < stamina_cost:
		if previous_state == PlayerEnums.PlayerStates.JUMP_STATE:
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.FALL_STATE, information)
		else:
			SignalManager.player_transition_state.emit(_previous_state, information)
		return

	super.enter(_previous_state)

	# Consume stamina
	player.stamina -= stamina_cost

	# Get dash direction (player-relative input or player forward)
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	var player_basis: Basis = player.global_transform.basis

	if input_dir != Vector2.ZERO:
		# Use movement direction from input (matches player-relative movement)
		dash_direction = -(player_basis.x * input_dir.x + player_basis.z * -input_dir.y).normalized()
	else:
		# Fallback to player's forward direction
		dash_direction = player_basis.z.normalized()

	# Ensure vertical component is flat
	dash_direction.y = 0

	# Initial velocity burst
	player.velocity = -dash_direction * dash_distance

	dash_duration_timer.start()


func physics_process(_delta: float) -> void:
	player.velocity = -dash_direction * dash_distance


func exit() -> void:
	dash_available = false
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
	dash_available = true
