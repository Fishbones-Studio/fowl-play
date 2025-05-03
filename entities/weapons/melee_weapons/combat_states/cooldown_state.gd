## CooldownState: The weapon is cooling down after an attack.
class_name CooldownState
extends BaseCombatState

# Variables
@onready var cooldown_timer: Timer = %CooldownTimer


func _init() -> void:
	state_type = WeaponEnums.WeaponState.COOLDOWN


# When entering this state, start the cooldown timer
func enter(_previous_state, _information: Dictionary = {}) -> void:
	if entity_stats.is_player:
		SignalManager.cooldown_item_slot.emit(weapon_node.current_weapon, weapon_node.current_weapon.cooldown_time, true)

	# Check if the cooldown time of weapon is lower or equal to 0, if so, return to idle state
	if weapon_node.current_weapon.cooldown_time <= 0:
		melee_combat_transition_state.emit(WeaponEnums.WeaponState.IDLE, {})
		return

	# Create a timer that lasts as long as the weapon's cooldown time
	cooldown_timer.wait_time = weapon_node.current_weapon.cooldown_time
	cooldown_timer.start()


# When exiting this state, stop and remove the cooldown timer
func exit() -> void:
	if cooldown_timer:
		cooldown_timer.stop()


# When the cooldown timer runs out, switch back to the IDLE state
func _on_cooldown_timer_timeout() -> void:
	melee_combat_transition_state.emit(WeaponEnums.WeaponState.IDLE, {})
