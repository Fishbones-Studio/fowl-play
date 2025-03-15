## WindupState: Prepares the weapon before attacking.
class_name WindupState extends BaseState

## Public Variables
var weapon_state_machine: Node3D
var windup_timer: float = 0.0


func enter() -> void:
	print("Entering Windup State")
	windup_timer = weapon_state_machine.current_weapon.windup_time

func process(delta: float) -> void:
	# Reduce the windup duration by the time passed since the last frame.
	windup_timer -= delta
	
	# If the windup timer reaches 0, switch to the attacking state.
	if windup_timer <= 0:
		weapon_state_machine.transition_to(WeaponEnums.WeaponState.ATTACKING)

func exit() -> void:
	pass
