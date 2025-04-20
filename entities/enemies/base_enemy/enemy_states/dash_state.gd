extends BaseEnemyState

var target_position: Vector3

var _stamina_cost: int
var _is_dashing: bool = false
var _target_rotation_reached: bool = false
var _dash_direction: Vector3
var _direction_difference: float

@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer


func enter(previous_state: EnemyEnums.EnemyStates, information: Dictionary = {}) -> void:
	super(previous_state)

	_stamina_cost = movement_component.dash_stamina_cost
	target_position = (player.position - enemy.position).normalized()

	if not movement_component.dash_available or enemy.stats.current_stamina < _stamina_cost:
		SignalManager.enemy_transition_state.emit(previous_state, information)
		return

	enemy.stats.drain_stamina(_stamina_cost)

	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	dash_duration_timer.start()
	dash_cooldown_timer.start()


func physics_process(delta: float) -> void:
	apply_gravity(delta)

	if _target_rotation_reached and movement_component.dash_available:
		_is_dashing = true
		movement_component.dash_available = false

	if not _is_dashing:
		_rotate_toward_direction(target_position, delta)

	if _is_dashing and _target_rotation_reached:
		_dash_direction = -enemy.global_basis.z # Default forward direction
		enemy.velocity = _dash_direction * enemy.stats.calculate_speed(movement_component.dash_speed_factor)
		enemy.move_and_slide()
		return


func _rotate_toward_direction(direction: Vector3, delta: float) -> void:
	var target_angle: float = atan2(-direction.x, -direction.z) # Calculate the angle to the target direction
	var current_angle: float = enemy.rotation.y # Get the current angle of the enemy

	# Lerp the angle to smoothly rotate towards the target direction
	var new_angle: float = lerp_angle(current_angle, target_angle, enemy.stats.calculate_speed(movement_component.dash_speed_factor) * delta)
	enemy.rotation.y = new_angle

	#calculate the difference bweteen the angles as they are always slightly different from one another.
	_direction_difference = abs(current_angle - target_angle)
	if _direction_difference < 0.5:
		_target_rotation_reached = true


func _on_dash_duration_timer_timeout() -> void:
	_is_dashing = false
	_target_rotation_reached = false

	SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.IDLE_STATE, {})


func _on_dash_cooldown_timer_timeout() -> void:
	movement_component.dash_available = true
