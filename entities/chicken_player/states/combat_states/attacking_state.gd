## AttackingState: The weapon is actively attacking.
class_name AttackingState
extends BaseCombatState

# Constants
const STATE_TYPE: int = WeaponEnums.MeleeState.ATTACKING
# Variables
var weapon: Node3D
var attack_timer: Timer
var chicken_player: Node3D
var hit_area: Area3D


# Set up the weapon and cache important nodes
func setup(weapon_node: Node3D) -> void:
	if not weapon_node:
		print("Weapon does not exist! Please provide a valid weapon node.")
		return

	weapon = weapon_node
	chicken_player = weapon.get_parent().get_parent()
	hit_area = chicken_player.get_node("HitArea")

	print("Weapon set successfully:", weapon.current_weapon.name)


# When entering this state, start the attack timer and attack
func enter(_previous_state, _information: Dictionary[String, float] = {}) -> void:
	print("Entering ATTACKING state")
	# Create a new timer that lasts as long as the weapon's attack duration
	attack_timer = Timer.new()
	attack_timer.wait_time = weapon.current_weapon.attack_duration
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)
	attack_timer.start()
	attack()








# When exiting this state, stop and remove the attack timer
func exit() -> void:
	if attack_timer:
		attack_timer.stop()
		attack_timer.queue_free()


# When the attack timer runs out, switch to the cooldown state
func _on_attack_timer_timeout() -> void:
	SignalManager.combat_transition_state.emit(WeaponEnums.MeleeState.COOLDOWN)


func attack() -> void:
	if not hit_area:
		print("HitArea not found!")
		return

	# Get all enemies inside the hit area
	var enemies = hit_area.get_overlapping_bodies()
	for enemy in enemies:
		if enemy is Enemy:
			enemy.take_damage(weapon.current_weapon.damage)
