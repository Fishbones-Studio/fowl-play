extends BaseEnemyState
@export var speed : int = 10
var target_position: Vector3
var in_attack_area : bool = false

func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	print ("enemy entered chase state")
	in_attack_area = false

#Check what conditions are fulfilled to shift the enemy in state to certain behaviour patterns.
#This would be the place to change behaviour, for example a ranged attack.
func physics_process(delta: float) -> void: 
	target_position = (player.position - enemy.position).normalized()
	
	if not in_attack_area && enemy.position.distance_to(player.position) < 3*chase_distance:
		enemy.look_at(player.position)
		enemy.velocity.x = target_position.x * speed
		enemy.velocity.z = target_position.z * speed
	elif in_attack_area:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.ATTACK_STATE, {})
	elif enemy.position.distance_to(player.position) > 2*chase_distance:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.IDLE_STATE, {})
	enemy.move_and_slide()

func _on_attack_area_body_entered(body: Node3D) -> void:
	in_attack_area = true
