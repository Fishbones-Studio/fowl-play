## State machine for the player melee system.
##
## This script manages the different states of the combat melee system, for the current melee weapon.
extends Node

@export var starting_state: BaseCombatState

var states: Dictionary[WeaponEnums.MeleeState, BaseCombatState] = {}

# The current active state (set when the scene loads)
@onready var current_state: BaseCombatState = _get_initial_state()
@onready var weapon: MeleeWeapon = $"../CurrentWeapon".current_weapon


func _ready() -> void:
	if weapon == null:
		push_error(owner.name + ": No weapon reference set")
	print("Set melee weapon:" + weapon.name)

	# Listen for state transition signals
	SignalManager.combat_transition_state.connect(_transition_to_next_state)

	# Wait for the owner to be ready before setting up states
	await owner.ready

	# Get all states in the scene and store them in the dictionary
	for state_node: BaseCombatState in get_children():
		states[state_node.STATE_TYPE] = state_node
		# Pass the weapon to each state
		state_node.setup(weapon)

	print(states)

	# Start in the initial state if it exists
	if current_state:
		current_state.enter(current_state.STATE_TYPE)


func _process(delta: float) -> void:
	if current_state == null:
		push_error(owner.name + ": No state set.")
		return
	# Run the active state's process function
	current_state.process(delta)


func _physics_process(delta: float) -> void:
	if current_state == null:
		push_error(owner.name + ": No state set.")
		return
	# Run the active state's physics process
	current_state.physics_process(delta)


func _input(event: InputEvent) -> void:
	if current_state == null:
		push_error(owner.name + ": No state set.")
		return
	# Pass input events to the current state
	current_state.input(event)


# Handles transitioning from one state to another
func _transition_to_next_state(target_state: WeaponEnums.MeleeState, information: Dictionary[String, float] = {}) -> void:
# Prevent transitioning to the same state
	if target_state == current_state.STATE_TYPE:
		push_error(owner.name + ": Trying to transition to the same state: " + str(target_state) + ". Falling back to idle.")
		target_state = WeaponEnums.MeleeState.IDLE
	
	# Exit the current state before switching
	var previous_state := current_state
	previous_state.exit()
	
	# Switch to the new state
	current_state = states.get(target_state)
	if current_state == null:
		push_error(owner.name + ": Trying to transition to state " + str(target_state) + " but it does not exist. Falling back to: " + str(previous_state))
		current_state = previous_state

	if(current_state.ANIMATION_NAME != null && !current_state.ANIMATION_NAME.is_empty() && weapon):
		# Play the animation for the new state
		weapon.animation_player.play(current_state.ANIMATION_NAME)
	
	# Enter the new state and carry over any necessary information
	current_state.enter(previous_state.STATE_TYPE, information)





# Gets the initial state when the game starts
func _get_initial_state() -> BaseCombatState:
	return starting_state if starting_state != null else get_child(0)
