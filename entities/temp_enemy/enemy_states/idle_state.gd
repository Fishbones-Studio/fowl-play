extends BaseEnemyState


var chase_distance := Vector3(5,0,5)



func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	print("enemy entered idle state")

func process(delta: float) -> void:
	if abs(enemy.global_position - GameManager.chicken_player.global_position).normalized() < chase_distance:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.CHASE_STATE, {})
