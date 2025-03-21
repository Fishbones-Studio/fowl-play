extends BaseEnemyState
@export var speed = 30
var player_position
var target_position

func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	print ("entered chase state")


func process(delta: float) -> void:
	
	player_position = player.position
	target_position = (player_position - enemy.position).normalized()
	
	if enemy.position.distance_to(player_position) > 5:
		enemy.move_and_slide()
		enemy.look_at(player_position)
