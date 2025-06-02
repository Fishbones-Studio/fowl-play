################################################################################
## Manages round transitions, enemy spawning, and battle flow.
## Handles enemy selection, round progression, and intermission logic.
################################################################################
class_name RoundHandler
extends Node

signal next_enemy_selected(enemy: Enemy)

@export_category("Round Settings")
## Default max rounds (overridden by round_setup)
@export var default_max_rounds: int = 3
## Enable/disable intermission between rounds
@export var intermission_enabled: bool = true
## Time between round transitions
@export var transition_delay: float = 2.0

var round_state: RoundEnums.RoundTypes = RoundEnums.RoundTypes.WAITING
var _next_enemy: Enemy = null
var _current_enemy: Enemy = null
var _enemy_scenes_by_type: Dictionary = {}

@onready var enemy_spawn_position: Marker3D = %EnemyPosition
@onready var player_spawn_position: Marker3D = %PlayerPosition

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


func _enter_waiting() -> void:
	SignalManager.add_ui_scene.emit(
		UIEnums.UI.ROUND_SCREEN,
		{"display_text": "Round %d" % GameManager.current_round}
	)

	GameManager.chicken_player.global_position = player_spawn_position.global_position
	await get_tree().create_timer(transition_delay).timeout

	round_state = RoundEnums.RoundTypes.IN_PROGRESS
	_start_round()


func _enter_in_progress() -> void:
	# Handle enemy selection
	if not _current_enemy:
		if _next_enemy:
			_current_enemy = _next_enemy
			_next_enemy = null
		else:
			# For the first round or when there's no next enemy set
			if GameManager.current_round == default_max_rounds:
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


func _enter_concluding() -> void:
	# Handle victory condition
	if GameManager.current_round == default_max_rounds:
		_handle_victory()
		return

	# Award currency
	var prosperity_eggs: int = GameManager.arena_round_reward.get(
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS, 0
	) * GameManager.current_round

	GameManager.prosperity_eggs += prosperity_eggs
	var currency_dict: Dictionary[CurrencyEnums.CurrencyTypes, int] = {
		CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS: prosperity_eggs
	}

	SignalManager.add_ui_scene.emit(
		UIEnums.UI.ROUND_SCREEN,
		{"display_text": "Enemy Defeated!", "currency_dict": currency_dict}
	)

	# Prepare next enemy
	if GameManager.current_round + 1 == default_max_rounds:
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

	# Advance round
	GameManager.current_round += 1
	round_state = (
		RoundEnums.RoundTypes.INTERMISSION
		if intermission_enabled
		else RoundEnums.RoundTypes.WAITING
	)
	_start_round()


func _enter_intermission() -> void:
	GameManager.chicken_player.global_position = Vector3(-400, 2.5, 0)
	SignalManager.upgrades_shop_refreshed.emit()


func _proceed_to_next_round() -> void:
	if round_state != RoundEnums.RoundTypes.INTERMISSION:
		push_error("Proceed called outside intermission state!")
		return

	round_state = RoundEnums.RoundTypes.WAITING
	_start_round()


func _create_enemy(type: EnemyEnums.EnemyTypes) -> Enemy:
	var scenes = _enemy_scenes_by_type.get(type, [])
	if scenes.is_empty():
		var type_name: String = "UNKNOWN_TYPE"
		# Get the enum name if possible
		if EnemyEnums.EnemyTypes.values().has(type):
			for key in EnemyEnums.EnemyTypes:
				if EnemyEnums.EnemyTypes[key] == type:
					type_name = key
					break
		else:
			type_name = str(type)
		
		push_warning("No enemies available for type: %s" % type_name)
		return null

	var scene = scenes.pick_random()
	return scene.instantiate() as Enemy


func _spawn_enemy() -> void:
	assert(_current_enemy, "Attempted to spawn null enemy!")

	if _current_enemy.get_parent():
		_current_enemy.get_parent().remove_child(_current_enemy)

	add_child(_current_enemy)
	_current_enemy.global_position = enemy_spawn_position.global_position

	# Connect death signal with cleanup
	var death_callback = func():
		if is_instance_valid(_current_enemy):
			_current_enemy.queue_free()
		_current_enemy = null
		SignalManager.enemy_died.emit()

	if is_instance_valid(_current_enemy):
		_current_enemy.tree_exiting.connect(death_callback, CONNECT_ONE_SHOT)
	else:
		push_error("RoundHandler: _current_enemy became invalid before connecting death_callback.")


func _handle_victory() -> void:
	var currency_dict: Dictionary[CurrencyEnums.CurrencyTypes, int] = {}
	for currency_type in GameManager.arena_completion_reward:
		var amount = GameManager.arena_completion_reward[currency_type]
		currency_dict[currency_type] = amount

		match currency_type:
			CurrencyEnums.CurrencyTypes.FEATHERS_OF_REBIRTH:
				GameManager.feathers_of_rebirth += amount
			CurrencyEnums.CurrencyTypes.PROSPERITY_EGGS:
				GameManager.prosperity_eggs += amount

	SignalManager.game_won.emit()
	SignalManager.add_ui_scene.emit(
		UIEnums.UI.VICTORY_SCREEN, {"currency_dict": currency_dict}
	)

func setup_rounds(enemies: Array[PackedScene], max_rounds: int) -> void:
	if enemies.is_empty():
		push_error("RoundHandler: No enemies provided for setup!")
		return

	if max_rounds > 0:
		default_max_rounds = max_rounds

	_categorize_enemies(enemies)
	GameManager.current_round = 1
	SignalManager.start_next_round.connect(_proceed_to_next_round)
	_start_round()
