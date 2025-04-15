extends Node

@export_category("Enemies")
@export var enemy_scenes: Array[PackedScene]

@export_category("Round Settings")
@export var max_rounds: int = 3
@export var round_intermission: bool = true
@export var battle_duration: float = 0 # Leave at 0 for no time limit
@export var intermission_duration: float # The duration for the intermissions

var round_state: RoundEnums.RoundTypes = RoundEnums.RoundTypes.WAITING
var available_enemies: Dictionary = {}

var _current_enemy: Enemy # The one currently in the arena fighting

@onready var enemy_position: Marker3D = $"../EnemyPosition" # Position where to spawn the enemy at
@onready var player_position: Marker3D = $"../PlayerPosition"
@onready var battle_timer: Timer = $RoundBattleTimer
@onready var intermission_timer: Timer = $RoundIntermissionTimer


func _ready() -> void:
	battle_timer.wait_time = battle_duration
	intermission_timer.wait_time = intermission_duration if round_intermission else 30.0

	battle_timer.timeout.connect(_on_battle_timer_timeout)
	intermission_timer.timeout.connect(_on_intermission_timer_timeout)

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
	if _current_enemy == null:
		print(available_enemies)
		
		_current_enemy = _pick_random_enemy(
			EnemyEnums.EnemyTypes.BOSS 
				if GameManager.current_round == max_rounds 
				else EnemyEnums.EnemyTypes.REGULAR
		)

	battle_timer.start()
	_spawn_enemy_in_level()


func _pick_random_enemy(enemy_type: EnemyEnums.EnemyTypes) -> Enemy:
	# Selects a random enemy from the pool, then remove it from the spawn pool to prevent fighting the same enemy and finally return the enemy instance
	return available_enemies[enemy_type].pop_at(randi_range(0, available_enemies[enemy_type].size() - 1))


func _spawn_enemy_in_level() -> void:
	assert(_current_enemy, "Missing current enemy")

	add_child(_current_enemy)
	_current_enemy.global_position = enemy_position.global_position

	SignalManager.enemy_died.connect(func():
		_current_enemy = null
		_start_round()
		, CONNECT_ONE_SHOT
	)


# This function probably won't be used, but who knows, maybe for tie breakers
# Compares both the ChickenPlayer and Enemy health and whoever has the lowest remaining health loses
func _on_battle_timer_timeout() -> void:
	if GameManager.chicken_player.stats.current_health > _current_enemy.stats.current_health:
		print("you have more hp and procceed to next round")
		# go to next round
	else:
		print("enemy has more hp and you lose, game over noob")
		# show game over screen


func _on_intermission_timer_timeout() -> void:
	pass
	
	_start_round()
