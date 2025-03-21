extends BaseEnemyState


var chase_distance := Vector3(5,0,5)

func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	print("idle state entered")

func process(delta: float) -> void:
	print(abs(enemy.global_position - player.global_position).normalized())
	if abs(enemy.global_position - player.global_position).normalized() < chase_distance:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.CHASE_STATE, {})
