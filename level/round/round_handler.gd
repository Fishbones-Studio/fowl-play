################################################################################
## Manages round transitions, enemy spawning, and battle flow.
## Handles enemy selection, round progression, and intermission logic.
################################################################################
class_name RoundHandler
extends Node

signal next_enemy_selected(enemy: Enemy)

@export_category("Round Settings")
## Default max rounds (overridden by round_setup)
@export var max_rounds: int = 3
## Enable/disable intermission between rounds
@export var intermission_enabled: bool = true
## Time between round transitions
@export var transition_delay: float = 2.0
@export_category("Spawn")
@export var enemy_spawn_position: Marker3D
@export var player_spawn_position: Marker3D
@export var intermission_spawn_position: Marker3D

var round_state: RoundEnums.RoundTypes = RoundEnums.RoundTypes.WAITING

var _next_enemy: Enemy = null # The next enemy to fight, decided after the previous round
var _current_enemy: Enemy = null # The one currently in the arena fighting
var _enemy_scenes_by_type: Dictionary = {} # Categorized enemy scenes by type
var _used_enemies: Array[PackedScene] = [] # Tracks enemies already spawned in the current run


## Sets up the round system with the provided enemies and max rounds.
func setup_rounds(enemies: Array[PackedScene], _max_rounds: int) -> void:
	if enemies.is_empty():
		push_error("RoundHandler: No enemies provided for setup!")
		return

	if _max_rounds > 0:
		max_rounds = _max_rounds

	_categorize_enemies(enemies)
	_used_enemies.clear() # Reset the used enemies list at the start of a new run
	GameManager.current_round = 1
	SignalManager.start_next_round.connect(_proceed_to_next_round)
	_start_round()


## Categorizes enemy scenes by their type for efficient selection.
func _categorize_enemies(enemies: Array[PackedScene]) -> void:
	_enemy_scenes_by_type.clear()

	for scene in enemies:
		var temp_enemy: Enemy = scene.instantiate() as Enemy
		if not temp_enemy:
			push_error(
				"RoundHandler: Invalid enemy scene: %s" % scene.resource_path
			)
			continue

		var enemy_type: EnemyEnums.EnemyTypes = temp_enemy.type
		if not _enemy_scenes_by_type.has(enemy_type):
			_enemy_scenes_by_type[enemy_type] = []

		_enemy_scenes_by_type[enemy_type].append(scene)
		temp_enemy.queue_free()


## Main round state machine entry point.
func _start_round() -> void:
	match round_state:
		RoundEnums.RoundTypes.WAITING:
			await _enter_waiting()
		RoundEnums.RoundTypes.IN_PROGRESS:
			await _enter_in_progress()
		RoundEnums.RoundTypes.CONCLUDING:
			await _enter_concluding()
		RoundEnums.RoundTypes.INTERMISSION:
			_enter_intermission()
		_:
			push_error("RoundHandler: Invalid state: %s" % round_state)


## Handles the waiting period before a round starts.
func _enter_waiting() -> void:
	var current_round_string: String = "Round " + NumberUtils.to_words(GameManager.current_round)
	if GameManager.current_round == max_rounds:
		current_round_string = "Final Round"
	SignalManager.add_ui_scene.emit(
		UIEnums.UI.ROUND_SCREEN,
		{"display_text": current_round_string}
	)

	GameManager.chicken_player.global_position = player_spawn_position.global_position
	GameManager.chicken_player.look_at(enemy_spawn_position.global_position)
	await get_tree().create_timer(transition_delay).timeout

	round_state = RoundEnums.RoundTypes.IN_PROGRESS
	_start_round()


## Handles the round in-progress state, including enemy selection and spawning.
func _enter_in_progress() -> void:
	# Use the pre-selected next_enemy if available, otherwise pick one (for the first round)
	if not _current_enemy:
		if _next_enemy:
			_current_enemy = _next_enemy
			_next_enemy = null
		else:
			# This case should only happen for the very first round
			if GameManager.current_round == max_rounds:
				_current_enemy = _create_enemy(EnemyEnums.EnemyTypes.BOSS)
				if not _current_enemy: # No boss enemies available
					printerr(
						"RoundHandler: No boss enemies available for the final round. Spawning a regular enemy instead."
					)
					_current_enemy = _create_enemy(EnemyEnums.EnemyTypes.REGULAR)
			else:
				_current_enemy = _create_enemy(EnemyEnums.EnemyTypes.REGULAR)

			if not _current_enemy:
				push_error(
					"RoundHandler: Critical - Failed to create any enemy for the current round."
				)
				return

	if not _current_enemy:
		push_error(
			"RoundHandler: _current_enemy is null before spawning. This should not happen."
		)
		return

	_spawn_enemy()
	SaveManager.save_enemy_encounter(_current_enemy.stats.name)

	# Wait for enemy defeat
	await SignalManager.enemy_died
	round_state = RoundEnums.RoundTypes.CONCLUDING
	_start_round()


## Handles the end of a round, including rewards and next enemy selection.
func _enter_concluding() -> void:
	# Check if all rounds are completed (boss defeated)
	if GameManager.current_round == max_rounds:
		_handle_victory()
		return

	var currency_dict := _handle_round_reward()

	# Show the round screen
	SignalManager.add_ui_scene.emit(
		UIEnums.UI.ROUND_SCREEN,
		{"display_text": "Enemy Defeated!", "currency_dict": currency_dict}
	)

	# Decide and store the next enemy *before* the wait time
	if GameManager.current_round + 1 == max_rounds:
		_next_enemy = _create_enemy(EnemyEnums.EnemyTypes.BOSS)
		if not _next_enemy: # No boss enemies available
			printerr(
				"RoundHandler: No boss enemies available for the upcoming final round. Preparing a regular enemy instead."
			)
			_next_enemy = _create_enemy(EnemyEnums.EnemyTypes.REGULAR)
	else:
		_next_enemy = _create_enemy(EnemyEnums.EnemyTypes.REGULAR)

	if _next_enemy:
		next_enemy_selected.emit(_next_enemy)
	else:
		push_error("RoundHandler: Critical - Failed to prepare any next enemy.")

	await get_tree().create_timer(transition_delay).timeout

	# Increment round *after* picking the next enemy and waiting
	GameManager.current_round += 1
	round_state = (
		RoundEnums.RoundTypes.INTERMISSION
		if intermission_enabled
		else RoundEnums.RoundTypes.WAITING
	)
	_start_round()


## Handles the intermission state, including player teleport and shop refresh.
func _enter_intermission() -> void:
	GameManager.chicken_player.global_position = intermission_spawn_position.global_position
	SignalManager.upgrades_shop_refreshed.emit()


## Method for handling normal round rewards
func _handle_round_reward() -> Dictionary[CurrencyEnums.CurrencyTypes, int]:
	# Add currency
	var prosperity_eggs: int = GameManager.arena_round_reward.get(
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS, 0
	) * GameManager.current_round

	GameManager.prosperity_eggs += prosperity_eggs
	return {
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS: prosperity_eggs
	} as Dictionary[CurrencyEnums.CurrencyTypes, int]


## Proceeds to the next round from intermission.
func _proceed_to_next_round() -> void:
	if round_state != RoundEnums.RoundTypes.INTERMISSION:
		push_error("Proceed called outside intermission state!")
		return

	round_state = RoundEnums.RoundTypes.WAITING
	_start_round()


## Instantiates a random enemy of the given type, avoiding repeats if possible.
func _create_enemy(type: EnemyEnums.EnemyTypes) -> Enemy:
	var all_scenes_for_type: Array = _enemy_scenes_by_type.get(
		type, []
	)

	if all_scenes_for_type.is_empty():
		push_warning(
			"RoundHandler: No enemy scenes available for type: %s" % str(type)
		)
		return null

	var available_unique_scenes: Array[PackedScene] = []
	for scene in all_scenes_for_type:
		if not _used_enemies.has(scene):
			available_unique_scenes.append(scene)

	var scene_to_instantiate: PackedScene = null

	if not available_unique_scenes.is_empty():
		# Prefer to pick an enemy that hasn't been used yet in this run
		scene_to_instantiate = available_unique_scenes.pick_random()
		if scene_to_instantiate:
			_used_enemies.append(scene_to_instantiate)
	else:
		# All unique enemies of this type have been used in this run.
		# Allow re-picking from the full list for this type.
		push_warning(
			(
				"RoundHandler: All unique enemies of type '%s' have been used in this run. "
				+ "Re-picking from the full list for this type."
			)
			% str(type)
		)
		scene_to_instantiate = all_scenes_for_type.pick_random()

	if not scene_to_instantiate:
		# This should ideally not happen if all_scenes_for_type was not empty
		push_error(
			"RoundHandler: Failed to select an enemy scene for type: %s"
			% str(type)
		)
		return null

	return scene_to_instantiate.instantiate() as Enemy


## Spawns the current enemy in the arena and connects its death signal.
func _spawn_enemy() -> void:
	assert(_current_enemy, "Attempted to spawn null enemy!")

	# Ensure the enemy node is not already in the tree if reusing instances
	if _current_enemy.get_parent():
		_current_enemy.get_parent().remove_child(_current_enemy)

	add_child(_current_enemy)
	_current_enemy.global_position = enemy_spawn_position.global_position
	_current_enemy.look_at(player_spawn_position.global_position)
	_current_enemy.scale_stats(GameManager.current_round)

	# Connect death signal (one-shot ensures it disconnects after firing)
	var death_callback = func():
		if is_instance_valid(_current_enemy):
			_current_enemy.queue_free()
		_current_enemy = null

	if is_instance_valid(_current_enemy):
		_current_enemy.tree_exiting.connect(death_callback, CONNECT_ONE_SHOT)
	else:
		push_error("RoundHandler: _current_enemy became invalid before connecting death_callback.")


## Handles the end-of-game victory logic and reward distribution.
func _handle_victory() -> void:
	var currency_dict: Dictionary[CurrencyEnums.CurrencyTypes, int] = {}
	if _current_enemy.type ==  EnemyEnums.EnemyTypes.BOSS:
		for currency_type in GameManager.arena_completion_reward:
			var amount = GameManager.arena_completion_reward[currency_type]
			currency_dict[currency_type] = amount
	
			match currency_type:
				CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
					GameManager.feathers_of_rebirth += amount
				CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
					GameManager.prosperity_eggs += amount
	else:
		currency_dict = _handle_round_reward()

	SignalManager.game_won.emit()
	SignalManager.add_ui_scene.emit(
		UIEnums.UI.VICTORY_SCREEN, {"currency_dict": currency_dict}
	)
