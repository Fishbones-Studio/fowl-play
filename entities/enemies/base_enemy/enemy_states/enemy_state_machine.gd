extends Node

@export var starting_state: BaseEnemyState
@export var enemy: Enemy
@export var movement_component: EnemyMovementComponent

var states: Dictionary[EnemyEnums.EnemyStates, BaseEnemyState] = {}
var player: ChickenPlayer

var current_state: BaseEnemyState
var previous_state: BaseEnemyState


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if enemy == null:
		push_error(owner.name + ": No enemy reference set")

	if player == null:
		player = GameManager.chicken_player

	if movement_component == null:
		push_error(owner.name + "No enemy movement component set")

	# Connect the signal to the transition function
	SignalManager.enemy_transition_state.connect(_transition_to_next_state)

	# We wait for the owner to be ready to guarantee all the data and nodes are available.
	await owner.ready

	# Get all states in the scene tree
	for state_node: BaseEnemyState in get_children():
		states[state_node.state_type] = state_node
		state_node.setup(enemy, player, movement_component)

	current_state = _get_initial_state()
	current_state.enter(current_state.state_type)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state == null:
		push_error(owner.name + ": No state set.")
		return
	current_state.process(delta)


func _physics_process(delta: float) -> void:
	if current_state == null:
		push_error(owner.name + ": No state set.")
		return
	current_state.physics_process(delta)


func _transition_to_next_state(target_state: EnemyEnums.EnemyStates, information: Dictionary = {}) -> void:
	previous_state = current_state
	previous_state.exit()
	
	print(target_state)

	current_state = states.get(target_state)

	if not current_state:
		push_error(owner.name + ": Trying to transition to state " + EnemyEnums.EnemyStates.find_key(target_state) + " but it does not exist. Falling back to: " + str(previous_state))
		current_state = previous_state


	current_state.enter(previous_state.state_type, information)


func _get_initial_state() -> BaseEnemyState:
	return starting_state if starting_state != null else get_child(0)
