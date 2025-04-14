## AttackingState: The weapon is actively attacking.
class_name AttackingState
extends BaseCombatState

# Constants
const STATE_TYPE: int = WeaponEnums.WeaponState.ATTACKING

var hit_area: Area3D

@onready var attack_timer: Timer = %AttackTimer

# Set up the weapon and cache important nodes
func setup(_weapon_node: MeleeWeapon, _melee_combat_transition_state: Signal) -> void:
	super(_weapon_node, _melee_combat_transition_state)
	hit_area = weapon_node.hit_area


# When entering this state, start the attack timer and attack
func enter(_previous_state, _information: Dictionary = {}) -> void:
	attack_timer.wait_time = weapon_node.current_weapon.attack_duration
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

	# Get targets for the given area in the attack area. 
	var targets: Array[Node3D] = hit_area.get_overlapping_bodies()
	for target in targets:
		if target is ChickenPlayer or target is Enemy:
			SignalManager.weapon_hit_target.emit(target, weapon_node.current_weapon.damage)
