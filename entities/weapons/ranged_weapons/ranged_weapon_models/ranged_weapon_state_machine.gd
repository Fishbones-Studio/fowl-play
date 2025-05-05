## State machine for the player melee system.
##
## This script manages the different states of the combat melee system, for the current melee weapon.
class_name RangedWeaponStateMachine 
extends Node

signal combat_transition_state(target_state: WeaponEnums.WeaponState, information: Dictionary)

@export var starting_state: BaseRangedCombatState
@export var weapon: RangedWeapon

var states: Dictionary[WeaponEnums.WeaponState, BaseRangedCombatState] = {}

# The current active state (set when the scene loads)
@onready var current_state: BaseRangedCombatState = _get_initial_state()


func _ready() -> void:
	if weapon == null:
		push_error(owner.name + ": No weapon reference set")

	# Listen for state transition signals
	combat_transition_state.connect(_transition_to_next_state)

	# Wait for the owner to be ready before setting up states
	await owner.ready

	# Get all states in the scene and store them in the dictionary
	for state_node: BaseRangedCombatState in get_children():
		states[state_node.state_type] = state_node
		# Pass the weapon to each state
		state_node.setup(weapon, combat_transition_state)
	print(states)

	# Start in the initial state if it exists
	if current_state:
		current_state.enter(current_state.state_type)


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
func _transition_to_next_state(target_state: WeaponEnums.WeaponState, information: Dictionary = {}) -> void:
	# Prevent transitioning to the same state
	if target_state == current_state.state_type:
		push_error(owner.name + ": Trying to transition to the same state: " + str(target_state) + ". Falling back to idle.")
		target_state = WeaponEnums.WeaponState.IDLE

	# Exit the current state before switching
	var previous_state := current_state
	previous_state.exit()

	# Switch to the new state
	current_state = states.get(target_state)
	if current_state == null:
		push_error(owner.name + ": Trying to transition to state " + str(target_state) + " but it does not exist. Falling back to: " + str(previous_state))
		current_state = previous_state

	# Animation handling
	var has_current_anim := current_state.ANIMATION_NAME != null \
		and not current_state.ANIMATION_NAME.is_empty() \
		and weapon \
		and weapon.animation_player.has_animation(current_state.ANIMATION_NAME)

	if has_current_anim:
		var anim_name: String = current_state.ANIMATION_NAME
		var anim: Animation   = weapon.animation_player.get_animation(anim_name)
		if anim and weapon.current_weapon.loop_animation:
			anim.loop = true
		weapon.animation_player.play(anim_name)
		
	# If the next state does not have an animation, play RESET or stop
	else:
		if weapon.animation_player.has_animation("RESET"):
			weapon.animation_player.play("RESET")
		else:
			weapon.animation_player.stop()


	print("Transitioning secondary weapon to state: " + WeaponEnums.weapon_state_to_string(current_state.state_type))

	# Enter the new state and carry over any necessary information
	current_state.enter(previous_state.state_type, information)
	

# Gets the initial state when the game starts
func _get_initial_state() -> BaseRangedCombatState:
	return starting_state if starting_state != null else get_child(0)
