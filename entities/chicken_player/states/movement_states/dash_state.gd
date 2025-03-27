## State handling player dash movement
## 
## Applies instant burst movement in facing direction with stamina cost
extends BasePlayerMovementState

var _stamina_cost: int

var _dash_available: bool = true
var _is_dashing: bool = false
var _dash_direction: Vector3

@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer


func enter(previous_state: BasePlayerMovementState, information: Dictionary = {}) -> void:
	super(previous_state)
	
	_stamina_cost = movement_component.dash_stamina_cost
	
	if not _dash_available or player.stats.current_stamina < _stamina_cost:
		print("dash not available")
		SignalManager.player_state_transitioned.emit(previous_state.state_type, information)
		return
	
	SignalManager.stamina_changed.emit(player.stats.drain_stamina(_stamina_cost))
	
	_dash_available = false
	_is_dashing = true
	
	_dash_direction = get_player_direction()
	if _dash_direction == Vector3.ZERO:
		_dash_direction = -player.global_basis.z
	
	dash_duration_timer.start()
	dash_cooldown_timer.start()


func physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if _is_dashing:
		player.velocity = _dash_direction * player.stats.calculate_speed(movement_component.dash_speed_factor)
		player.move_and_slide()
		return
	
	if get_jump_velocity() > 0 and movement_component.jump_available:
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.JUMP_STATE, {})
	
	if player.is_on_floor():
		var direction = get_player_direction()
		
		if direction == Vector3.ZERO:
			SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.IDLE_STATE, {})
			return
		
		if Input.is_action_pressed("sprint") and player.stats.current_stamina > 0:
			SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.SPRINT_STATE, {})
			return
		
		SignalManager.player_state_transitioned.emit(PlayerEnums.PlayerStates.WALK_STATE, {})
		return
	
	player.move_and_slide()


func _on_dash_duration_timer_timeout():
	_is_dashing = false


func _on_dash_cooldown_timer_timeout():
	print("dash available again")
	_dash_available = true
