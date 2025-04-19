extends BaseEnemyState

var target_position: Vector3
var base_timer_duration: float
@export var lower_chase_duration_limit: float = 1.0
@onready var chase_duration: Timer = $ChaseDuration


func setup(_enemy: Enemy, _player: ChickenPlayer, _movement_component: EnemyMovementComponent) -> void:
	if _enemy == null:
		push_error(owner.name + ": No enemy reference set" + str(state_type))
	enemy = _enemy
	if _player == null:
		push_error(owner.name + ": No player reference set" + str(state_type))
	player = _player
	if _movement_component == null:
		push_error(owner.name + ": No movement component reference set" + str(state_type))
	movement_component = _movement_component
	base_timer_duration = chase_duration.wait_time

func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	#reduce chase_duration the lower the boss health gets, and set a lower limit
	chase_duration.wait_time = base_timer_duration * (enemy.stats.current_health / enemy.stats.max_health)
	if (chase_duration.wait_time > lower_chase_duration_limit):
		chase_duration.wait_time = lower_chase_duration_limit
	target_position = (player.position - enemy.position).normalized()
	calculated_speed = enemy.stats.calculate_speed(movement_component.walk_speed_factor)

#Check what conditions are fulfilled to shift the enemy in state to certain behaviour patterns.
#This would be the place to change behaviour, for example a ranged attack.
func physics_process(delta: float) -> void:
	apply_gravity(delta)
	if not _target_rotation_reached:
		_rotate_toward_direction(target_position, delta, calculated_speed)
	#added timer start here to make sure the timer is started at intuitive time, meaning when the action starts.
	if _target_rotation_reached:
		if chase_duration.is_stopped():
			chase_duration.start()
		apply_movement(target_position * calculated_speed)
		enemy.move_and_slide()
		return


func _on_chase_duration_timeout() -> void:
	SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.IDLE_STATE, {})
