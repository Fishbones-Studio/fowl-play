extends BaseEnemyState

@export var attack_area : Area3D
@export var damage : int

func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	print("enemy entered attack state")
	
func attack_player():
	var bodies = attack_area.get_overlapping_bodies()
	
	
	for body in bodies:
		if body is ChickenPlayer:
			SignalManager.hurt_player.emit(damage)
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.HURT_STATE)
		


func _on_area_3d_body_entered(body: Node3D) -> void:
	attack_player()


func _on_attack_area_body_exited(body: Node3D) -> void:
	SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.IDLE_STATE)
