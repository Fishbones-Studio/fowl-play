## AttackingState: The weapon is actively attacking.
class_name AttackingState
extends BaseCombatState

# Constants
const STATE_TYPE: int = WeaponEnums.MeleeState.ATTACKING

@onready var attack_timer: Timer = %AttackTimer

var hit_area: Area3D

# Set up the weapon and cache important nodes
func setup(weapon_node: Weapon) -> void:
	super(weapon_node)
	if not weapon_node:
		print("Weapon does not exist! Please provide a valid weapon node.")
		return
	hit_area = weapon.hit_area
	attack_timer.wait_time = weapon.current_weapon.attack_duration

	print("Weapon set successfully:", weapon.current_weapon.name)

# When entering this state, start the attack timer and attack
func enter(_previous_state, _information: Dictionary[String, float] = {}) -> void:
	print("Player attacking")
	attack_timer.start()
	_attack()


# When exiting this state, stop and remove the attack timer
func exit() -> void:
	if attack_timer:
		attack_timer.stop()


# When the attack timer runs out, switch to the cooldown state
func _on_attack_timer_timeout() -> void:
	SignalManager.combat_transition_state.emit(WeaponEnums.MeleeState.COOLDOWN)


func _attack() -> void:
	if not hit_area:
		print("HitArea not found!")
		return

	# Get all enemies inside the hit area
	var enemies: Array[Node3D] = hit_area.get_overlapping_bodies()
	for enemy in enemies:
		if enemy is Enemy:
			enemy.take_damage(weapon.current_weapon.damage)
