extends BaseEnemyState
@export var speed: int = 10
@export var rotation_speed: float = 5.0   ## How quickly enemy turns toward target
var target_position: Vector3


func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	# Connect body entered signal
	SignalManager.weapon_hit_area_body_entered.connect(_on_attack_area_body_entered)


func exit() -> void:
	# Disconnect body entered signal
	SignalManager.weapon_hit_area_body_entered.disconnect(_on_attack_area_body_entered)


#Check what conditions are fulfilled to shift the enemy in state to certain behaviour patterns.
#This would be the place to change behaviour, for example a ranged attack.
func physics_process(delta: float) -> void:
	target_position = (player.position - enemy.position).normalized()
	if enemy.position.distance_to(player.position) < chase_distance:
		if target_position.length() > 0:
			_rotate_toward_direction(target_position, delta)
		enemy.velocity.x = target_position.x * speed
		enemy.velocity.z = target_position.z * speed
	else:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.IDLE_STATE, {})


func _on_attack_area_body_entered(body: PhysicsBody3D) -> void:
	# TODO this only triggers once, if you stay in the body, the enemy will stop atacking after 1 time
	if body == player:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.ATTACK_STATE, {})

func _rotate_toward_direction(direction: Vector3, delta: float) -> void:
	var target_angle: float = atan2(-direction.x, -direction.z) # Calculate the angle to the target direction
	var current_angle: float = enemy.rotation.y # Get the current angle of the enemy

	# Lerp the angle to smoothly rotate towards the target direction
	var new_angle := lerp_angle(current_angle, target_angle, rotation_speed * delta)
	enemy.rotation.y = new_angle
