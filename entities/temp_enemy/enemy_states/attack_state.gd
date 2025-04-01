extends BaseEnemyState

@export var damage: int


func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	attack_player()
	# Connect body exited signal
	SignalManager.weapon_hit_area_body_exited.connect(_on_attack_area_body_exited)


func exit() -> void:
	# Disconnect body exited signal
	SignalManager.weapon_hit_area_body_exited.disconnect(_on_attack_area_body_exited)


#Deal damage to the player when they enter the attack_area of the enemy
func attack_player():
	SignalManager.hurt_player.emit(damage)
	SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.HURT_STATE, {})


#Reset enemy after the player leaves the attack area of the enemy
func _on_attack_area_body_exited(body: PhysicsBody3D) -> void:
	if body == player:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.IDLE_STATE)
