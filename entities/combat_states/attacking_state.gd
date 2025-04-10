## AttackingState: The weapon is actively attacking.
class_name AttackingState
extends BaseCombatState

# Constants
const STATE_TYPE: int = WeaponEnums.WeaponState.ATTACKING

var hit_area: Area3D

@onready var attack_timer: Timer = %AttackTimer

# Set up the weapon and cache important nodes
func setup(weapon_node: MeleeWeapon, melee_combat_transition_state: Signal, root_actor: CharacterBody3D) -> void:
	super(weapon_node, melee_combat_transition_state, root_actor)
	hit_area = weapon_node.hit_area


# When entering this state, start the attack timer and attack
func enter(_previous_state, _information: Dictionary = {}) -> void:
	attack_timer.wait_time = weapon.current_weapon.attack_duration
	attack_timer.start()
	_attack()


# When exiting this state, stop and remove the attack timer
func exit() -> void:
	if attack_timer:
		attack_timer.stop()


# When the attack timer runs out, switch to the cooldown state
func _on_attack_timer_timeout() -> void:
	melee_combat_transition_state.emit(WeaponEnums.WeaponState.COOLDOWN)


func _attack() -> void:
	if not hit_area:
		print("HitArea not found!")
		return
	var dash_attack_roll : int
		#Condition for checking if the attacking entity is a Enemy that can perform a certain attack.
	if(root_actor == Enemy):
		dash_attack_roll = randi_range(0,3)
		
	# Get targets for the given area in the attack area. Check which actor is making the attack
	# and corresponding to what actor makes the attack deal damage to certain types of targets
	if (dash_attack_roll == 3):
		pass
	var targets: Array[Node3D] = hit_area.get_overlapping_bodies()
	if(root_actor == GameManager.chicken_player):
		for target in targets:
			if target is Enemy:
				SignalManager.weapon_hit_target.emit(target, weapon.current_weapon.damage)
	else:
		for target in targets:
			if target == GameManager.chicken_player:
				SignalManager.weapon_hit_target.emit(target, weapon.current_weapon.damage)
	
