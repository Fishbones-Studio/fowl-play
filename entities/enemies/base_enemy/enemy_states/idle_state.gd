extends BaseEnemyState

@export_category("Enemy Movement")
@export var wander_interval: float = 3.0  ## Time between choosing new wander directions
@export var wander_speed: float = 3.0
@export var wander_radius: float = 8.0   ## Max distance from starting point
@export var rotation_speed: float = 5.0   ## How quickly enemy turns toward target

@export_category("Enemy Dash")
@export_range(1, 100) var dash_treshold: int = 100
@export_range(1, 100) var dash_chance: int = 25

var target_position: Vector3 ## Target position for wandering
var wander_timer: float = wander_interval ## Timer for choosing new target
var origin_position: Vector3 ## Starting position of the enemy


func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	origin_position = enemy.position
	_choose_new_wander_target()


func process(_delta: float) -> void:
	if enemy.position.distance_to(player.position) < chase_distance:
		if randi_range(1, dash_treshold) <= dash_chance and movement_component.dash_available:
			SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.DASH_STATE, {})
			return
		else:
			SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.CHASE_STATE, {})
			return


func physics_process(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0:
		_choose_new_wander_target()
		wander_timer = wander_interval

	var direction: Vector3 = (target_position - enemy.position).normalized()
	if direction.length() > 0:
		_rotate_toward_direction(direction, delta)

	apply_movement(Vector3(direction.x * wander_speed, 0, direction.z * wander_speed))
	apply_gravity(delta)


func _choose_new_wander_target() -> void:
	var random_angle: float = randf_range(0, 2 * PI) # Random angle in radians
	var random_distance: float = randf_range(0, wander_radius) # Random distance from the origin position

	# Calculate the target position based on the random angle and distance
	target_position = origin_position + Vector3(
		cos(random_angle) * random_distance,
		0,
		sin(random_angle) * random_distance
	)

	# Ensure the target position is within the wander radius, if not, adjust it
	if origin_position.distance_to(target_position) > wander_radius:
		target_position = origin_position + (target_position - origin_position).normalized() * wander_radius


func _rotate_toward_direction(direction: Vector3, delta: float) -> void:
	var target_angle: float = atan2(-direction.x, -direction.z) # Calculate the angle to the target direction
	var current_angle: float = enemy.rotation.y # Get the current angle of the enemy

	# Lerp the angle to smoothly rotate towards the target direction
	var new_angle : float = lerp_angle(current_angle, target_angle, rotation_speed * delta)
	enemy.rotation.y = new_angle
