extends BaseEnemyState
@export var speed : int = 10
var target_position: Vector3
	

func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	# Connect body entered signal
	SignalManager.weapon_hit_area_body_entered.connect(_on_attack_area_body_entered)
	
func exit() -> void:
	# Disconnect body entered signal
	SignalManager.weapon_hit_area_body_entered.disconnect(_on_attack_area_body_entered)

#Check what conditions are fulfilled to shift the enemy in state to certain behaviour patterns.
#This would be the place to change behaviour, for example a ranged attack.
func physics_process(_delta: float) -> void:
	target_position = (player.position - enemy.position).normalized()
	if enemy.position.distance_to(player.position) < 2 * chase_distance:
		enemy.look_at(player.position)
		enemy.velocity.x = target_position.x * speed
		enemy.velocity.z = target_position.z * speed
	else:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.IDLE_STATE, {})
	enemy.move_and_slide()

func _on_attack_area_body_entered(body: PhysicsBody3D) -> void:
	if body == ChickenPlayer:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.ATTACK_STATE, {})
