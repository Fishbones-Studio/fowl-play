## CooldownState: The weapon is cooling down after an attack.
class_name CooldownState
extends BaseState

# Constants
const STATE_TYPE = WeaponEnums.MeleeState.COOLDOWN  # Defines this state as COOLDOWN

# Variables
var weapon: Node3D  # The weapon that is cooling down
var cooldown_timer: Timer  # Timer to track cooldown duration-

# Sets up the weapon reference
func setup(weapon_node: Node3D) -> void:
	weapon = weapon_node

# When entering this state, start the cooldown timer
func enter(previous_state, information: Dictionary[String, float] = {}) -> void:
	print("Entering COOLDOWN state")

	# Create a timer that lasts as long as the weapon's cooldown time
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = weapon.current_weapon.cooldown_time
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	add_child(cooldown_timer)

	cooldown_timer.start()

# When exiting this state, stop and remove the cooldown timer
func exit() -> void:
	if cooldown_timer:
		cooldown_timer.stop()
		cooldown_timer.queue_free()

# When the cooldown timer runs out, switch back to the IDLE state
func _on_cooldown_timer_timeout() -> void:
	SignalManager.combat_transition_state.emit(WeaponEnums.MeleeState.IDLE)
