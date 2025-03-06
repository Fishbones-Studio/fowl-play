extends Node

@export var starting_state: BasePlayerState
@export var player: ChickenPlayer

@onready var current_state: BasePlayerState = get_initial_state()

var states: Dictionary[PlayerEnums.PlayerStates, BasePlayerState] = {}


func get_initial_state() -> BasePlayerState:
	return starting_state if starting_state != null else get_child(0)


func _ready() -> void:
	if player == null:
		push_error(owner.name + ": No player reference set")
		
	# Connect the signal to the transition function
	SignalManager.player_transition_state.connect(_transition_to_next_state)

	# We wait for the owner to be ready to guarantee all the data and nodes are available.
	await owner.ready

	# Get all states in the scene tree
	for state_node: BasePlayerState in get_children():
		states[state_node.STATE_TYPE] = state_node
		state_node.setup(player)

	print(states)

	if current_state:
		current_state.enter(current_state.STATE_TYPE)


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


func _transition_to_next_state(target_state: PlayerEnums.PlayerStates, information : Dictionary = {}) -> void:
	var previous_state := current_state
	previous_state.exit()
	
	current_state = states.get(target_state)
	if current_state == null:
		push_error(owner.name + ": Trying to transition to state " + str(target_state) + " but it does not exist. Falling back to: " + str(previous_state))
		current_state = previous_state
	
	# TODO: start animation of the state
		
	current_state.enter(previous_state.STATE_TYPE, information)

func _input(event: InputEvent) -> void:
	if current_state == null:
		push_error(owner.name + ": No state set.")
		return
	current_state.input(event)
