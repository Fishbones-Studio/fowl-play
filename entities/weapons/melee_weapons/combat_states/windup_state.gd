## WindupState: The weapon is preparing to attack.
class_name WindupState
extends BaseCombatState

# Variables
@onready var windup_timer: Timer = %WindupTimer


func _init():
	state_type = WeaponEnums.WeaponState.WINDUP


# When entering this state, start the windup timer
func enter(_previous_state, _information: Dictionary = {}) -> void:
	if weapon_node.current_weapon.windup_time <= 0:
		melee_combat_transition_state.emit(WeaponEnums.WeaponState.ATTACKING, {})
		return
	elif weapon_node.current_weapon.windup_time > 0:
		windup_timer.wait_time = weapon_node.current_weapon.windup_time
		windup_timer.start()


# When exiting this state, stop the windup timer
func exit() -> void:
	if windup_timer:
		windup_timer.stop()


# When the windup timer runs out, switch to the ATTACKING state
func _on_windup_timer_timeout() -> void:
	melee_combat_transition_state.emit(WeaponEnums.WeaponState.ATTACKING, {})
