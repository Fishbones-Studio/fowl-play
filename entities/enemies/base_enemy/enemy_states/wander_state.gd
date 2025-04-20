extends BaseEnemyState

@export var wander_interval: float = 3.0
@export var wander_radius: float = 8.0
@export var rotation_speed: float = 5.0

var target_position: Vector3
var wander_timer: float
var origin_position: Vector3
var calculated_speed: float


func enter(previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	super(previous_state)

	origin_position = enemy.position
	wander_timer = wander_interval
	_choose_new_wander_target()

	animation_tree.get("parameters/MovementStateMachine/playback").travel(self.name)


func process(delta: float) -> void:
	wander_timer -= delta

	if wander_timer <= 0 or enemy.position.distance_to(player.position) < chase_distance:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.IDLE_STATE, {})
		return


func physics_process(delta: float) -> void:
	apply_gravity(delta)

	var to_target: Vector3 = target_position - enemy.position
	var distance_to_target: float = to_target.length()

	if distance_to_target > 0.4:
		var direction: Vector3 = to_target.normalized()
		calculated_speed = enemy.stats.calculate_speed(movement_component.walk_speed_factor)
		_rotate_toward_direction(direction, delta)
		apply_movement(direction * calculated_speed)
	else:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.IDLE_STATE, {})


func _choose_new_wander_target() -> void:
	var random_angle: float = randf_range(0, 2 * PI)
	var random_distance: float = randf_range(0, wander_radius)

	target_position = origin_position + Vector3(
		cos(random_angle) * random_distance,
		0,
		sin(random_angle) * random_distance
	)

	# Ensure the target position is within the wander radius, if not, adjust it
	if origin_position.distance_to(target_position) > wander_radius:
		target_position = origin_position + (target_position - origin_position).normalized() * wander_radius


func _rotate_toward_direction(direction: Vector3, delta: float) -> void:
	var target_angle: float = atan2(-direction.x, -direction.z)
	var current_angle: float = enemy.rotation.y
	var new_angle: float = lerp_angle(current_angle, target_angle, rotation_speed * delta)
	enemy.rotation.y = new_angle
