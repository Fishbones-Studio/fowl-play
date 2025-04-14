## CooldownState: The weapon is cooling down after an attack.
class_name CooldownState
extends BaseCombatState

# Constants
const STATE_TYPE: int = WeaponEnums.WeaponState.COOLDOWN  # Defines this state as COOLDOWN
# Variables
@onready var cooldown_timer: Timer = %CooldownTimer


# When entering this state, start the cooldown timer
func enter(_previous_state, _information: Dictionary = {}) -> void:
	# Create a timer that lasts as long as the weapon's cooldown time
	cooldown_timer.wait_time = weapon_node.current_weapon.attack_duration
	cooldown_timer.start()


# When exiting this state, stop and remove the cooldown timer
func exit() -> void:
	if cooldown_timer:
		cooldown_timer.stop()


# When the cooldown timer runs out, switch back to the IDLE state
func _on_cooldown_timer_timeout() -> void:
	melee_combat_transition_state.emit(WeaponEnums.WeaponState.IDLE, {})
