## IdleState: The weapon is idle and waiting for input.
class_name IdleState
extends BaseState

# Constants
# Defines this state as IDLE
const STATE_TYPE = WeaponEnums.MeleeState.IDLE  

# Variables
# Handy to have for idle animation
var weapon: Node3D  


func setup(weapon_node: Node3D) -> void:
	weapon = weapon_node

# When entering this state
func enter(previous_state, information: Dictionary[String, float] = {}) -> void:
	print("Entering IDLE state")

# Checks for player input (attack button press)
func input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		# Switch to the WINDUP state when attacking
		SignalManager.combat_transition_state.emit(WeaponEnums.MeleeState.WINDUP)
