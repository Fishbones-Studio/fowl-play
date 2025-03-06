## State handling player dash movement
## 
## Applies instant burst movement in facing direction with stamina cost
extends BasePlayerState

@export_range(10, 100) var stamina_cost: int = 30
@export_range(1.0, 20.0) var dash_distance: float = 50.0

#TODO fix, wrong direction and doesnt go back

@onready var dash_duration_timer : Timer = $DashDurationTimer
@onready var dash_cooldown_timer : Timer = $DashCooldownTimer

var dash_available: bool = true
var dash_direction: Vector3
	
	
func enter(_previous_state : PlayerEnums.PlayerStates, information : Dictionary = {}) -> void:
	player.velocity.y = 0
	
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

	# Get normalized dash direction from camera basis
	dash_direction = player.player_camera_transformer.global_transform.basis.z.normalized()
	dash_direction.y = 0

	# Initial velocity burst
	player.velocity = dash_direction * dash_distance
	
	dash_duration_timer.start()
	
func physics_process(delta: float) -> void:
	player.velocity = dash_direction * dash_distance * delta * 60
	
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
