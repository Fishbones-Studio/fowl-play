## AttackingState: The weapon is actively attacking.
class_name AttackingState
extends BaseCombatState

# Constants
const STATE_TYPE: int = WeaponEnums.WeaponState.ATTACKING

var hit_area: Area3D

@onready var attack_timer: Timer = %AttackTimer


# Set up the weapon and cache important nodes
func setup(weapon_node: MeleeWeapon) -> void:
	super(weapon_node)
	hit_area = weapon_node.hit_area


# When entering this state, start the attack timer and attack
func enter(_previous_state, _information: Dictionary[String, float] = {}) -> void:
	attack_timer.wait_time = weapon.current_weapon.attack_duration
	attack_timer.start()
	_attack()


# When exiting this state, stop and remove the attack timer
func exit() -> void:
	if attack_timer:
		attack_timer.stop()


# When the attack timer runs out, switch to the cooldown state
func _on_attack_timer_timeout() -> void:
	SignalManager.combat_transition_state.emit(WeaponEnums.WeaponState.COOLDOWN)


func _attack() -> void:
	if not hit_area:
		print("HitArea not found!")
		return

	# Get all enemies inside the hit area
	var enemies: Array[Node3D] = hit_area.get_overlapping_bodies()
	for enemy in enemies:
		if enemy is Enemy:
			enemy.take_damage(weapon.current_weapon.damage)
