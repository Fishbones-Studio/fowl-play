class_name ChickenPlayer
extends CharacterBody3D

@export var stats: LivingEntityStats

@onready var movement_state_machine: MovementStateMachine = $MovementStateMachine
@onready var animation_tree: AnimationTree = %AnimationTree


func _ready() -> void:
	# load the stats from the save manager
	stats = SaveManager.get_loaded_player_stats()
	if stats == null:
		push_error("Failed to load player stats from SaveManager!")
		return
	stats = GameManager.apply_cheat_settings(stats, stats.duplicate(), true)
	stats.init()
	GameManager.chicken_player = self

	SignalManager.init_health.emit(stats.max_health, stats.current_health)
	SignalManager.init_stamina.emit(stats.max_stamina, stats.current_stamina)
	SignalManager.weapon_hit_target.connect(_on_weapon_hit_target)


func _input(event: InputEvent) -> void:
	movement_state_machine.input(event)


func _process(delta: float) -> void:
	movement_state_machine.process(delta)
	SignalManager.player_stats_changed.emit(stats)


func _physics_process(delta: float) -> void:
	movement_state_machine.physics_process(delta)


func _exit_tree() -> void:
	print("ChickenPlayer exited tree")
	GameManager.chicken_player = null


func get_stats_resource() -> LivingEntityStats:
	if stats == null:
		push_warning("Attempted to get stats resource before it was assigned!")
	return stats


func _on_weapon_hit_target(target: PhysicsBody3D, damage: int, type: DamageEnums.DamageTypes, info: Dictionary = {}) -> void:
	if target == self:
		stats.drain_health(damage, type)
		SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.HURT_STATE, info)
