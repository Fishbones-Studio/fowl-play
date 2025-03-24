extends BaseEnemyState

var target_position : Vector3

func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	print("enemy entered idle state")

#Check if Player is close enough, will be true 99% of the time by design. Doubt this specific state is extremely useful but can be used as a reset for the enemy.
func process(delta: float) -> void:
	target_position = (player.position - enemy.position).normalized()
	if enemy.position.distance_to(player.position) < chase_distance:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.CHASE_STATE, {})
