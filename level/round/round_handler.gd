extends Node

const ROUND_COUNTDOWN_SCENE: PackedScene = preload("uid://cobwc3aaxw4i8")

@export_category("Enemies")
@export var enemy_scenes: Array[PackedScene]

@export_category("Round Settings")
@export var max_rounds: int = 3
@export var round_intermission: bool = true
@export var round_timer: bool = false # If enabled, match lasts 120 seconds
@export var waiting_time: float

var round_state: RoundEnums.RoundTypes = RoundEnums.RoundTypes.WAITING
var available_enemies: Dictionary = {}

var _current_enemy: Enemy # The one currently in the arena fighting

@onready var enemy_position: Marker3D = $"../EnemyPosition" # Position where to spawn the enemy at
@onready var player_position: Marker3D = $"../PlayerPosition"
@onready var battle_timer: Timer = $RoundBattleTimer
@onready var intermission_timer: Timer = $RoundIntermissionTimer


func _ready() -> void:
	GameManager.current_round = 1
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
			round_state = RoundEnums.RoundTypes.IN_PROGRESS
		RoundEnums.RoundTypes.IN_PROGRESS:
			_enter_in_progress()
			round_state = RoundEnums.RoundTypes.CONCLUDING
		RoundEnums.RoundTypes.CONCLUDING:
			_enter_concluding()
			round_state = RoundEnums.RoundTypes.INTERMISSION if round_intermission else RoundEnums.RoundTypes.WAITING
		RoundEnums.RoundTypes.INTERMISSION:
			_enter_intermission()
			round_state = RoundEnums.RoundTypes.WAITING
		_:
			assert(false, "Invalid RoundState: %s" % str(round_state))


func _enter_waiting() -> void:
	SignalManager.add_ui_scene.emit("uid://61l26wjx0fux", {"display_text": "Round %d" % GameManager.current_round})
	GameManager.chicken_player.global_position = player_position.global_position

	await get_tree().create_timer(waiting_time).timeout

	_start_round()


func _enter_in_progress() -> void:
	if _current_enemy == null:
		_current_enemy = _pick_random_enemy(
			EnemyEnums.EnemyTypes.BOSS 
				if GameManager.current_round == max_rounds 
				else EnemyEnums.EnemyTypes.REGULAR
		)

	_spawn_enemy_in_level()

	await SignalManager.enemy_died

	_start_round()


func _enter_concluding() -> void:
	if GameManager.current_round == max_rounds: # crack way to check if boss dead
		print("boss is dead, wooahaha!!!")
		SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
		return

	SignalManager.add_ui_scene.emit("uid://61l26wjx0fux", {"display_text": "Enemy defeated!"})

	await get_tree().create_timer(waiting_time).timeout

	GameManager.current_round += 1

	_start_round()


func _enter_intermission() -> void:
	assert(ROUND_COUNTDOWN_SCENE is PackedScene, "ROUND_COUNTDOWN_SCENE is not a valid PackedScene")

	var countdown_instance: Control = ROUND_COUNTDOWN_SCENE.instantiate()
	add_child(countdown_instance)

	intermission_timer.start()

	# TODO, shop somewhere to interact
	print("imagine you are now in a different part of arena with a shop")

	while intermission_timer.time_left > 0:
		countdown_instance.update_countdown(ceil(intermission_timer.time_left))
		await get_tree().create_timer(1.0).timeout

	countdown_instance.queue_free()


# Selects a random enemy from the pool, then remove it from the spawn pool to prevent fighting the same enemy and finally return the enemy instance
func _pick_random_enemy(enemy_type: EnemyEnums.EnemyTypes) -> Enemy:
	return available_enemies[enemy_type].pop_at(randi_range(0, available_enemies[enemy_type].size() - 1))


func _spawn_enemy_in_level() -> void:
	assert(_current_enemy, "Missing current enemy")

	add_child(_current_enemy)
	_current_enemy.global_position = enemy_position.global_position

	SignalManager.enemy_died.connect(func(): _current_enemy = null, CONNECT_ONE_SHOT)


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
	_start_round()
