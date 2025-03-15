## IdleState: The default state where the weapon waits for player input.
class_name IdleState extends BaseState

## Public Variables
var weapon_state_machine: Node3D


func enter() -> void:
	print("Entering Idle State")

func process(delta: float) -> void:
	# Listen for the attack input and transition to the windup state.
	if Input.is_action_just_pressed("attack"):
		weapon_state_machine.transition_to(WeaponEnums.WeaponState.WINDUP)

func exit() -> void:
	pass
