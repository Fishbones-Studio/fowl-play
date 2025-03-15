class_name IdleState extends BaseState

var weapon_state_machine: Node3D

func enter():
	print("Entering Idle State")

func process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		weapon_state_machine.transition_to(WeaponEnums.WeaponState.WINDUP)

func exit() -> void:
	pass
