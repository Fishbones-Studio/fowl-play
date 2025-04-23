extends BaseEnemyState

@export_range(1, 100, 1) var dash_treshold: int = 100
@export_range(0, 100, 1) var dash_chance: int


func enter(_previous_state: EnemyEnums.EnemyStates, _information: Dictionary = {}) -> void:
	super(_previous_state)

	animation_tree.get("parameters/MovementStateMachine/playback").travel(self.name)


func process(_delta: float) -> void:
	if enemy.position.distance_to(player.position) < chase_distance:
		if randi_range(1, dash_treshold) <= dash_chance and movement_component.dash_available:
			SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.DASH_STATE, {})
		else:
			SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.CHASE_STATE, {})
	else:
		SignalManager.enemy_transition_state.emit(EnemyEnums.EnemyStates.WANDER_STATE, {})


func physics_process(delta: float) -> void:
	apply_gravity(delta)
