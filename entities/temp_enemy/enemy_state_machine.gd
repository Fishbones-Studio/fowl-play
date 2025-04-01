extends Node

@export var starting_state: BaseEnemyState
@export var enemy: Enemy
@export var player: ChickenPlayer

var states: Dictionary[EnemyEnums.EnemyStates, BaseEnemyState] = {}

@onready var current_state: BaseEnemyState = _get_initial_state()
@onready var weapon: MeleeWeapon = $"../CurrentWeapon".current_weapon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(current_state)
	if enemy == null:
		push_error(owner.name + ": No enemy reference set")

	if player == null:
		player = GameManager.chicken_player

	# Connect the signal to the transition function
	SignalManager.enemy_transition_state.connect(_transition_to_next_state)

	# We wait for the owner to be ready to guarantee all the data and nodes are available.
	await owner.ready

	# Get all states in the scene tree
	for state_node: BaseEnemyState in get_children():
		states[state_node.STATE_TYPE] = state_node
		state_node.setup(enemy, weapon, player)

	print(states)

	if current_state:
		current_state.enter(current_state.STATE_TYPE)


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
	if target_state == current_state.STATE_TYPE:
		push_error(owner.name + ": Trying to transition to the same state: " + str(target_state) + ". Falling back to idle.")
		target_state = EnemyEnums.EnemyStates.IDLE_STATE

	var previous_state := current_state
	previous_state.exit()

	current_state = states.get(target_state)
	if current_state == null:
		push_error(owner.name + ": Trying to transition to state " + str(target_state) + " but it does not exist. Falling back to: " + str(previous_state))
		current_state = previous_state

	# TODO: start animation of the state
	if(current_state.ANIMATION_NAME != null && !current_state.ANIMATION_NAME.is_empty() && weapon):
		# Play the animation for the new state
		weapon.animation_player.play(current_state.ANIMATION_NAME)

	current_state.enter(previous_state.STATE_TYPE, information)


func _get_initial_state() -> BaseEnemyState:
	return starting_state if starting_state != null else get_child(0)
