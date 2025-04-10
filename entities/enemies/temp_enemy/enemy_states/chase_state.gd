extends BaseEnemyState
@export var rotation_speed: float = 5.0   ## How quickly enemy turns toward target
var target_position: Vector3


#Check what conditions are fulfilled to shift the enemy in state to certain behaviour patterns.
#This would be the place to change behaviour, for example a ranged attack.
func physics_process(delta: float) -> void:
	target_position = (player.position - enemy.position).normalized()
	if enemy.position.distance_to(player.position) < chase_distance:
		if target_position.length() > 0:
			_rotate_toward_direction(target_position, delta)
		apply_movement(target_position * enemy.stats.calculate_speed(movement_component.walk_speed_factor))
		apply_gravity(delta)
	else:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.IDLE_STATE, {})


func _rotate_toward_direction(direction: Vector3, delta: float) -> void:
	var target_angle: float = atan2(-direction.x, -direction.z) # Calculate the angle to the target direction
	var current_angle: float = enemy.rotation.y # Get the current angle of the enemy

	# Lerp the angle to smoothly rotate towards the target direction
	var new_angle : float = lerp_angle(current_angle, target_angle, rotation_speed * delta)
	enemy.rotation.y = new_angle
