## WindupState: The weapon is preparing to attack.
class_name WindupState
extends BaseCombatState

# Constants
const STATE_TYPE: int = WeaponEnums.MeleeState.WINDUP
# Variables
@onready var windup_timer: Timer = $WindupTimer


# Sets up the weapon reference
func setup(weapon_node: Node3D) -> void:
	weapon = weapon_node
	windup_timer.wait_time = weapon.current_weapon.windup_time


# When entering this state, start the windup timer
func enter(_previous_state, _information: Dictionary[String, float] = {}) -> void:
	if weapon.current_weapon.windup_time <= 0:
		SignalManager.combat_transition_state.emit(WeaponEnums.MeleeState.ATTACKING)
		return
	elif weapon.current_weapon.windup_time >= 0:
		windup_timer.start()


# When exiting this state, stop the windup timer
func exit() -> void:
	if windup_timer:
		windup_timer.stop()


# When the windup timer runs out, switch to the ATTACKING state
func _on_windup_timer_timeout() -> void:
	SignalManager.combat_transition_state.emit(WeaponEnums.MeleeState.ATTACKING)
