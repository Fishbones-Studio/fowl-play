class_name WindupState extends BaseState

var weapon_state_machine: Node3D
var windup_timer: float

func enter():
	print("Entering Windup State")
	windup_timer = weapon_state_machine.current_weapon.windup_time

func process(delta: float) -> void:
	# Reduce the winup duration by the time passed since the last frame.
	windup_timer -= delta
	
	# if the windup timer reaches 0 we switch to the attack state
	if windup_timer <= 0:
		weapon_state_machine.transition_to(WeaponEnums.WeaponState.ATTACKING)
