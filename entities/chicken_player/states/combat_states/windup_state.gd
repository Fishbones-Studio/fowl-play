## WindupState: The weapon is preparing to attack.
class_name WindupState
extends BaseCombatState

# Constants
const STATE_TYPE = WeaponEnums.MeleeState.WINDUP
# Variables
var weapon: Node3D
var windup_timer: Timer


# Sets up the weapon reference
func setup(weapon_node: Node3D) -> void:
	weapon = weapon_node


# When entering this state, start the windup timer
func enter(previous_state, information: Dictionary[String, float] = {}) -> void:
	print("Entering WINDUP state")
	if weapon.current_weapon.windup_time <= 0:
		SignalManager.combat_transition_state.emit(WeaponEnums.MeleeState.ATTACKING)
		return
	elif weapon.current_weapon.windup_time >= 0:
		# Create a timer that lasts as long as the weapon's windup time
		windup_timer = Timer.new()
		windup_timer.wait_time = weapon.current_weapon.windup_time
		windup_timer.one_shot = true
		windup_timer.timeout.connect(_on_windup_timer_timeout)
		add_child(windup_timer)

		windup_timer.start()




# When exiting this state, stop and remove the windup timer
func exit() -> void:
	if windup_timer:
		windup_timer.stop()
		windup_timer.queue_free()


# When the windup timer runs out, switch to the ATTACKING state
func _on_windup_timer_timeout() -> void:
	SignalManager.combat_transition_state.emit(WeaponEnums.MeleeState.ATTACKING)
