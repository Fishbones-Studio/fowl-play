################################################################################
## State machine for the player movement system.
##
## This script manages the different states of the player movement system, 
## for the chicken player.
################################################################################
class_name MovementStateMachine
extends Node

@export var starting_state: BasePlayerMovementState
@export var player: ChickenPlayer
@export var movement_component: PlayerMovementComponent

var states: Dictionary[PlayerEnums.PlayerStates, BasePlayerMovementState] = {}

var current_state: BasePlayerMovementState
var previous_state: BasePlayerMovementState


func _ready() -> void:
	if player == null:
		push_error(name + ": No player reference set")
	
	if movement_component == null:
		push_error(name + ": No movement component reference set")
	
	SignalManager.player_transition_state.connect(_transition_to_next_state)
	
	# Ensure owner is ready before accessing data and nodes.
	await owner.ready
	
	# Retrieve and initialize all state nodes in the scene tree
	for state_node: BasePlayerMovementState in get_children():
		states[state_node.state_type] = state_node
		state_node.player = player
		state_node.movement_component = movement_component
	
	current_state = _get_initial_state()
	current_state.enter(current_state)


func input(event: InputEvent) -> void:
	if current_state == null:
		push_error(name + ": No state set.")
		return
	current_state.input(event)


func process(delta: float) -> void:
	if current_state == null:
		push_error(name + ": No state set.")
		return
	current_state.process(delta)


func physics_process(delta: float) -> void:
	if current_state == null:
		push_error(name + ": No state set.")
		return
	current_state.physics_process(delta)


func _transition_to_next_state(target_state: PlayerEnums.PlayerStates, info: Dictionary = {} ) -> void:
	previous_state = current_state
	previous_state.exit()
	
	current_state = states.get(target_state)
	
	if not current_state:
		push_error(name + ": Trying to transition to state " + PlayerEnums.PlayerStates.find_key(target_state) + " but it does not exist. Falling back to: " + str(previous_state))
		current_state = previous_state
	
	current_state.enter(previous_state, info)


## Return the starting state if set, else return the first child of this object
func _get_initial_state() -> BasePlayerMovementState:
	return starting_state if starting_state else get_child(0)
