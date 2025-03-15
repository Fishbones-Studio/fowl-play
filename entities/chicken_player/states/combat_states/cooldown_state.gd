class_name CooldownState extends BaseState

var weapon_state_machine: Node3D
var cooldown_timer: float

func enter():
	print("Entering Cooldown State")
	cooldown_timer = weapon_state_machine.current_weapon.cooldown_time

func process(delta: float) -> void:
	# Reduce the cooldown duration by the time passed since the last frame.
	cooldown_timer -= delta
	
	# if cooldown timer is 0 we switch to the idle state
	if cooldown_timer <= 0:
		weapon_state_machine.transition_to(WeaponEnums.WeaponState.IDLE)

func exit() -> void:
	pass
