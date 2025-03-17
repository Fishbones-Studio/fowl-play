## AttackingState: Handles the attack phase of the weapon state machine.
class_name AttackingState extends BaseState

## Public Variables
var weapon_state_machine: Node3D
var current_weapon: Node3D
var attack_duration: float = 0.0


func enter() -> void:
	print("Entering Attacking State")
   
	attack_duration = weapon_state_machine.current_weapon.attack_duration

	# Call the attack logic once when entering the ATTACKING state.
	attack()

func process(delta: float) -> void:
	# Reduce the attack duration by the time passed since the last frame.
	attack_duration -= delta

	# Check if the attack duration is over.
	if attack_duration <= 0:
		# Transition to the Cooldown State.
		weapon_state_machine.transition_to(WeaponEnums.WeaponState.COOLDOWN)
		

func attack():
	var enemies = current_weapon.hitbox.get_overlapping_bodies()
	# We search for a class named Enemy within our hitbox
	for enemy in enemies:
		if enemy is Enemy:
			enemy.take_damage(current_weapon.damage)
