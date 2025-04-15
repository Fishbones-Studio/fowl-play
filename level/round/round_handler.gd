extends Node

@export_category("Enemies")
@export var enemy_scenes: Array[PackedScene]

@export_category("Round Settings")
@export var max_rounds: int = 3
@export var round_intermission: bool = true
@export var round_timer: bool = false # If enabled, match lasts 120 seconds

var round_state: RoundEnums.RoundTypes = RoundEnums.RoundTypes.WAITING
var available_enemies: Dictionary = {}

var _current_enemy: Enemy # The one currently in the arena fighting

@onready var enemy_position: Marker3D = $"../EnemyPosition" # Position where to spawn the enemy at
@onready var player_position: Marker3D = $"../PlayerPosition"
@onready var battle_timer: Timer = $RoundBattleTimer
@onready var intermission_timer: Timer = $RoundIntermissionTimer


func _ready() -> void:
	_init_enemies()
	_start_round()


func _init_enemies() -> void:
	available_enemies.clear()

	for child in enemy_scenes:
		var enemy_instance: Enemy = child.instantiate()
		assert(enemy_instance != null, "Failed to instantiate enemy scene")

		var enemy_type: EnemyEnums.EnemyTypes = enemy_instance.get_enemy_type()

		if not available_enemies.has(enemy_type):
			available_enemies[enemy_type] = []
		available_enemies[enemy_type].append(enemy_instance)


func _start_round() -> void:
	match round_state:
		RoundEnums.RoundTypes.WAITING:
			_enter_waiting()
		RoundEnums.RoundTypes.IN_PROGRESS:
			_enter_in_progress()
		RoundEnums.RoundTypes.CONCLUDING:
			_enter_concluding()
		RoundEnums.RoundTypes.INTERMISSION:
			_enter_intermission()
		_:
			assert(false, "Invalid RoundState: %s" % str(round_state))


func _enter_waiting() -> void:
	print("in waiting")
	GameManager.chicken_player.global_position = player_position.global_position

	round_state = RoundEnums.RoundTypes.IN_PROGRESS

	await get_tree().create_timer(5.0).timeout

	_start_round()


func _enter_in_progress() -> void:
	print("in progress")
	if _current_enemy == null:
		_current_enemy = _pick_random_enemy(
			EnemyEnums.EnemyTypes.BOSS
				if GameManager.current_round == max_rounds 
				else EnemyEnums.EnemyTypes.REGULAR
		)

	_spawn_enemy_in_level()

	await SignalManager.enemy_died
	round_state = RoundEnums.RoundTypes.CONCLUDING
	_start_round()


func _enter_concluding() -> void:
	print("in concluding")
	round_state = RoundEnums.RoundTypes.INTERMISSION
	
	await get_tree().create_timer(5.0).timeout

	_start_round()
	

func _enter_intermission() -> void:
	print("in intermission")
	intermission_timer.start()

	# Player should teleport to some area where they can interact with shop and heal
	print("imagine you are now in a different part of arena")


func _pick_random_enemy(enemy_type: EnemyEnums.EnemyTypes) -> Enemy:
	# Selects a random enemy from the pool, then remove it from the spawn pool to prevent fighting the same enemy and finally return the enemy instance
	return available_enemies[enemy_type].pop_at(randi_range(0, available_enemies[enemy_type].size() - 1))


func _spawn_enemy_in_level() -> void:
	assert(_current_enemy, "Missing current enemy")

	add_child(_current_enemy)
	_current_enemy.global_position = enemy_position.global_position

	SignalManager.enemy_died.connect(func():
		_current_enemy = null
		, CONNECT_ONE_SHOT
	)


# This function probably won't be used, but who knows, maybe for tie breakers
# Compares both the ChickenPlayer and Enemy health and whoever has the lowest remaining health loses
func _on_round_battle_timer_timeout() -> void:
	if GameManager.chicken_player.stats.current_health > _current_enemy.stats.current_health:
		print("you have more hp and procceed to next round")
		# go to next round
	else:
		print("enemy has more hp and you lose, game over noob")
		# show game over screen


func _on_round_intermission_timer_timeout() -> void:
	round_state = RoundEnums.RoundTypes.WAITING # Reset back to waiting

	_start_round()
