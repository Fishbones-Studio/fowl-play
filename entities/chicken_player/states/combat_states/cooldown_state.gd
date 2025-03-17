## CooldownState: Handles the cooldown phase of the weapon state machine.
class_name CooldownState extends BaseState

## Public Variables
var weapon_state_machine: Node3D
var cooldown_timer: float = 0.0


func enter() -> void:
	print("Entering Cooldown State")
	cooldown_timer = weapon_state_machine.current_weapon.cooldown_time

func process(delta: float) -> void:
	# Reduce the cooldown duration by the time passed since the last frame.
	cooldown_timer -= delta
	
	# If cooldown timer reaches 0, switch to the idle state.
	if cooldown_timer <= 0:
		weapon_state_machine.transition_to(WeaponEnums.WeaponState.IDLE)
