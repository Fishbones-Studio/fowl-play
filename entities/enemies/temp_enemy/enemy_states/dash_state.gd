extends BaseEnemyState


var _stamina_cost: int
var _is_dashing: bool = false
var _dash_direction: Vector3

@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer


func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	previous_state = _previous_state

	_stamina_cost = movement_component.dash_stamina_cost

	# Handle state transitions
	if not movement_component.dash_available or enemy.stats.current_stamina < _stamina_cost:
		print("Dash available: ", movement_component.dash_available)
		SignalManager.enemy_transition_state.emit(_previous_state, _information)
		return
		
	enemy.stats.drain_stamina(_stamina_cost)
	
	movement_component.dash_available = false
	_is_dashing = true
	_dash_direction = -enemy.global_basis.z # Default forward direction
	dash_duration_timer.start()
	dash_cooldown_timer.start()


func physics_process(delta: float) -> void:
	apply_gravity(delta)


func _on_dash_duration_timer_timeout():
	_is_dashing = false


func _on_dash_cooldown_timer_timeout():
	print("Dash available: ", movement_component.dash_available)
	movement_component.dash_available = true
