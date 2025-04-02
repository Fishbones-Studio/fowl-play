## IdleState: The weapon is idle and waiting for input.
class_name IdleState
extends BaseCombatState

# Constants
# Defines this state as IDLE
const STATE_TYPE: int = WeaponEnums.WeaponState.IDLE


# Checks for player input (attack button press)
func input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		# Switch to the WINDUP state when attacking
		SignalManager.combat_transition_state.emit(WeaponEnums.WeaponState.WINDUP)
