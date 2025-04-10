## WindupState: The weapon is preparing to attack.
class_name WindupState
extends BaseCombatState

# Constants
const STATE_TYPE: int = WeaponEnums.WeaponState.WINDUP
# Variables
@onready var windup_timer: Timer = %WindupTimer


# When entering this state, start the windup timer
func enter(_previous_state, _information: Dictionary = {}) -> void:
	if weapon.current_weapon.windup_time <= 0:
		melee_combat_transition_state.emit(WeaponEnums.WeaponState.ATTACKING, {})
		return
	elif weapon.current_weapon.windup_time > 0:
		windup_timer.wait_time = weapon.current_weapon.windup_time
		windup_timer.start()


# When exiting this state, stop the windup timer
func exit() -> void:
	if windup_timer:
		windup_timer.stop()


# When the windup timer runs out, switch to the ATTACKING state
func _on_windup_timer_timeout() -> void:
	melee_combat_transition_state.emit(WeaponEnums.WeaponState.ATTACKING, {})
