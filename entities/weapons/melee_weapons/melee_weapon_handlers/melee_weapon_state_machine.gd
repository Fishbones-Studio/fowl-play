## State machine for the player melee system.
##
## This script manages the different states of the combat melee system, for the current melee weapon.
class_name MeleeWeaponStateMachine
extends Node

signal melee_combat_transition_state(target_state: WeaponEnums.WeaponState, information: Dictionary)

@export var starting_state: BaseCombatState

var states: Dictionary[WeaponEnums.WeaponState, BaseCombatState] = {}
var weapon: MeleeWeapon
## Variable to track if setup has run yet
var initialized: bool = false

# The current active state (set when the scene loads)
@onready var current_state: BaseCombatState = _get_initial_state()


func setup(_weapon: MeleeWeapon, _entity_stats: LivingEntityStats) -> void:
	weapon = _weapon

	if weapon == null:
		push_error(owner.name + ": No weapon reference set. " + owner.name )

	# Listen for state transition signals

	melee_combat_transition_state.connect(_transition_to_next_state)

	# Get all states in the scene and store them in the dictionary
	for state_node: BaseCombatState in get_children():
		states[state_node.state_type] = state_node
		# Pass the weapon to each state
		state_node.setup(weapon, melee_combat_transition_state, _entity_stats)

	# Start in the initial state if it exists
	if current_state:
		current_state.enter(current_state.state_type)

	initialized = true


# Check if the root actor is an enemy if so, use process behaviour
func _process(delta: float) -> void:
	if initialized:
		if current_state == null:
			push_error(owner.name + ": No state set.")
			return

		current_state.process(delta)


func _physics_process(delta: float) -> void:
	if initialized:
		if current_state == null:
			push_error(owner.name + ": No state set.")
			return
		# Run the active state's physics process
		current_state.physics_process(delta)


# Handles transitioning from one state to another, checks if the one sending the transition is the one receiving it.
func _transition_to_next_state(target_state: WeaponEnums.WeaponState, information: Dictionary = {}) -> void:
	# Prevent transitioning to the same state
	if target_state == current_state.state_type:
		push_warning(owner.name + ": Trying to transition to the same state: " + str(target_state) + ". Falling back to idle.")
		target_state = WeaponEnums.WeaponState.IDLE

	# Exit the current state before switching
	var previous_state: BaseCombatState = current_state
	previous_state.exit()

	# Switch to the new state
	current_state = states.get(target_state)
	if current_state == null:
		push_error(owner.name + ": Trying to transition to state " + str(target_state) + " but it does not exist. Falling back to: " + str(previous_state))
		current_state = previous_state

	if weapon and weapon.animation_player:
		# Animation handling
		var has_current_anim: bool = current_state.animation_name != null \
				and not current_state.animation_name.is_empty() \
				and weapon \
				and weapon.animation_player.has_animation(current_state.animation_name)
	
		if has_current_anim:
			var anim_name: String = current_state.animation_name
			if anim_name == "Idle" : return # we don't want to immediatly play the idle animation. Idle animation plays on an interval in the idle state
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

	# Enter the new state and carry over any necessary information
	current_state.enter(previous_state.state_type, information)


# Gets the initial state when the game starts
func _get_initial_state() -> BaseCombatState:
	return starting_state if starting_state != null else get_child(0)


func update_entity_stats(_entity_stats : LivingEntityStats) -> void:
	print("Updating the weapon entity stats")
	for state_node: BaseCombatState in get_children():
		states[state_node.state_type] = state_node
		# Pass the weapon to each state
		state_node.entity_stats = _entity_stats
