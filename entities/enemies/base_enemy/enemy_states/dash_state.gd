extends BaseEnemyState

var _stamina_cost: int
var _is_dashing: bool = false
var _target_rotation_reached: bool = false
var _dash_direction: Vector3
var _direction_difference: float
var target_position: Vector3

@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer


func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	print ("entered dash state")
	previous_state = _previous_state
	_stamina_cost = movement_component.dash_stamina_cost
	target_position = (player.position - enemy.position).normalized()
	enemy.stats.drain_stamina(_stamina_cost)
	


func physics_process(delta: float) -> void:
	apply_gravity(delta)
	if _target_rotation_reached && movement_component.dash_available:
		_is_dashing = true
		movement_component.dash_available = false
	if !_is_dashing:
		_rotate_toward_direction(target_position, delta)
	if _is_dashing && _target_rotation_reached:
		if dash_duration_timer.is_stopped() && dash_cooldown_timer.is_stopped():
			dash_duration_timer.start()
			dash_cooldown_timer.start()
		_dash_direction = -enemy.global_basis.z # Default forward direction
		enemy.velocity = _dash_direction * enemy.stats.calculate_speed(movement_component.dash_speed_factor)
		enemy.move_and_slide()
		return


func _on_dash_duration_timer_timeout():
	print("dash timer timeout")
	#_is_dashing = false
	#_target_rotation_reached = false
	SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.IDLE_STATE, {})
	dash_duration_timer.stop()


func _on_dash_cooldown_timer_timeout():
	print("dash cooldown timer timeout")
	movement_component.dash_available = true
	dash_cooldown_timer.stop()


func _rotate_toward_direction(direction: Vector3, delta: float) -> void:
	var target_angle: float = atan2(-direction.x, -direction.z) # Calculate the angle to the target direction
	var current_angle: float = enemy.rotation.y # Get the current angle of the enemy

	# Lerp the angle to smoothly rotate towards the target direction
	var new_angle : float = lerp_angle(current_angle, target_angle, enemy.stats.calculate_speed(movement_component.dash_speed_factor) * delta)
	enemy.rotation.y = new_angle
	#calculate the difference bweteen the angles as they are always slightly different from one another.
	_direction_difference = abs(current_angle - target_angle)
	if _direction_difference < 0.5:
		_target_rotation_reached = true
