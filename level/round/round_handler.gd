################################################################################
## Manages round transitions, including enemy spawning, max rounds, and intermissions.
## Controls the battle timer and intermission duration, ensuring smooth round flow.
## Handles the random selection of enemies based on the current round.
###################################################################
class_name RoundHandler 
extends Node

signal next_enemy_selected(enemy: Enemy)

@export_category("Enemies")
@export var enemy_scenes: Array[PackedScene]

@export_category("Round Settings")
@export var max_rounds: int = 3
@export var round_intermission: bool = true
@export var waiting_time: float

var round_state: RoundEnums.RoundTypes = RoundEnums.RoundTypes.WAITING
var available_enemies: Dictionary[EnemyEnums.EnemyTypes, Array] = {}

var _next_enemy: Enemy = null # The next enemy to fight, decided after the previous round
var _current_enemy: Enemy = null # The one currently in the arena fighting

@onready var enemy_default_position: Marker3D = %EnemyPosition # Position where to spawn the enemy at
@onready var player_default_position: Marker3D = %PlayerPosition

# TODO (in future branch), since gamemanager has a current enemy now, we can just use that to spawn the enemy model in the intermission area


func _ready() -> void:
	GameManager.current_round = 1
	_init_enemies()
	_start_round()
	SignalManager.start_next_round.connect(_proceed_to_next_round)


func _proceed_to_next_round() -> void:
	# Ensure we are actually in the intermission state before proceeding
	if round_state != RoundEnums.RoundTypes.INTERMISSION:
		printerr("Tried to proceed from intermission, but not in intermission state!")
		return

	# Set the state to WAITING for the next round
	round_state = RoundEnums.RoundTypes.WAITING
	# Trigger the state machine to enter the WAITING state (_enter_waiting)
	_start_round()


func _init_enemies() -> void:
	available_enemies.clear()

	for scene in enemy_scenes:
		var enemy_instance: Enemy = scene.instantiate()
		assert(enemy_instance != null, "Failed to instantiate enemy scene")

		var enemy_type: EnemyEnums.EnemyTypes = enemy_instance.type

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
		RoundEnums.RoundTypes.INTERMISSION:
			_enter_intermission()
		_:
			assert(false, "Invalid RoundState: %s" % str(round_state))


func _enter_waiting() -> void:
	SignalManager.add_ui_scene.emit(
		UIEnums.UI.ROUND_SCREEN,
		{"display_text": "Round %d" % GameManager.current_round}
	)
	GameManager.chicken_player.global_position = player_default_position.global_position

	await get_tree().create_timer(waiting_time).timeout

	_start_round()


func _enter_in_progress() -> void:
	# Use the pre-selected next_enemy if available, otherwise pick one (for the first round)
	if _current_enemy == null:
		if _next_enemy != null:
			_current_enemy = _next_enemy
			_next_enemy = null # Clear the stored next enemy
		else:
			# This case should only happen for the very first round
			var first_enemy_type: EnemyEnums.EnemyTypes = (
				EnemyEnums.EnemyTypes.BOSS
				if GameManager.current_round == max_rounds
				else EnemyEnums.EnemyTypes.REGULAR
			)
			_current_enemy = _pick_random_enemy(first_enemy_type)

	_spawn_enemy_in_level()
	
	SaveManager.save_enemy_encounter(_current_enemy.stats.name)

	await SignalManager.enemy_died

	_start_round()


func _enter_concluding() -> void:
	# Check if all rounds are completed (boss defeated)
	if (
		GameManager.current_round == max_rounds
		and _current_enemy == null # Ensure the enemy is actually defeated
	):
		print("all rounds completed, back to poultry man menu")
		GameManager.prosperity_eggs += GameManager.arena_completion_reward
		GameManager.feathers_of_rebirth += 5 # TODO: improve later
		SignalManager.switch_game_scene.emit("uid://21r458rvciqo")
		# Don't proceed further in this function if game is ending
		return

	# Display enemy defeated message
	if _current_enemy == null:
		SignalManager.add_ui_scene.emit(
			UIEnums.UI.ROUND_SCREEN, {"display_text": "Enemy defeated!"}
		)

	# Decide and store the next enemy *before* the wait time
	# Ensure we don't try to pick an enemy after the last round
	if GameManager.current_round < max_rounds:
		var next_round_number: int = GameManager.current_round + 1
		var next_enemy_type: EnemyEnums.EnemyTypes = (
			EnemyEnums.EnemyTypes.BOSS
			if next_round_number == max_rounds
			else EnemyEnums.EnemyTypes.REGULAR
		)
		# Check if there are available enemies of the required type
		if (
			available_enemies.has(next_enemy_type)
			and not available_enemies[next_enemy_type].is_empty()
		):
			_next_enemy = _pick_random_enemy(next_enemy_type)
			next_enemy_selected.emit(_next_enemy) # Emit signal for UI/intermission
		else:
			printerr(
				"No available enemies of type %s for round %d!"
				% [EnemyEnums.EnemyTypes.keys()[next_enemy_type], next_round_number]
			)
			# TODO: maybe end game or spawn a default?

	# Wait before proceeding
	await get_tree().create_timer(waiting_time).timeout

	# Increment round *after* picking the next enemy and waiting
	GameManager.current_round += 1

	# Set next state and start it
	round_state = (
		RoundEnums.RoundTypes.INTERMISSION
		if round_intermission
		else RoundEnums.RoundTypes.WAITING
	)
	_start_round()


func _enter_intermission() -> void:
	GameManager.chicken_player.global_position = Vector3(
		-400, 2.5, 0
	) # teleport player to the intermission area
	SignalManager.upgrades_shop_refreshed.emit()
	# TODO: spawn next enemy in the intermission area


# Selects a random enemy instance from the pool, removes it, and returns it
func _pick_random_enemy(enemy_type: EnemyEnums.EnemyTypes) -> Enemy:
	if (
		not available_enemies.has(enemy_type)
		or available_enemies[enemy_type].is_empty()
	):
		printerr(
			"Attempted to pick an enemy of type %s, but none are available!"
			% EnemyEnums.EnemyTypes.keys()[enemy_type]
		)
		return null # Or handle error appropriately

	var index: int = randi_range(0, available_enemies[enemy_type].size() - 1)
	var picked_enemy: Enemy = available_enemies[enemy_type].pop_at(index)
	return picked_enemy


func _spawn_enemy_in_level() -> void:
	assert(_current_enemy != null, "Missing current enemy for spawning")

	# Ensure the enemy node is not already in the tree if reusing instances
	if _current_enemy.get_parent() != null:
		_current_enemy.get_parent().remove_child(_current_enemy)

	add_child(_current_enemy)
	_current_enemy.global_position = enemy_default_position.global_position

	# Connect death signal (one-shot ensures it disconnects after firing)
	SignalManager.enemy_died.connect(
		func(): _current_enemy = null, CONNECT_ONE_SHOT
	)
