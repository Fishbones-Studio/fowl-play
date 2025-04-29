## AttackingState: The weapon is actively attacking.
class_name AttackingState
extends BaseCombatState

# Constants
const STATE_TYPE: int = WeaponEnums.WeaponState.ATTACKING

@onready var attack_timer: Timer = %AttackTimer

# When entering this state, start the attack timer and attack
func enter(_previous_state, _information: Dictionary = {}) -> void:
	weapon_node.attacking = true
	if entity_stats.is_player: 
		SignalManager.cooldown_item_slot.emit(weapon_node.current_weapon, weapon_node.current_weapon.attack_duration, false)
	attack_timer.wait_time = weapon_node.current_weapon.attack_duration
	attack_timer.start()
	
func physics_process(_delta: float) -> void:
	_attack()


# When exiting this state, stop and remove the attack timer
func exit() -> void:
	weapon_node.attacking = false
	if attack_timer:
		attack_timer.stop()


# When the attack timer runs out, switch to the cooldown state
func _on_attack_timer_timeout() -> void:
	melee_combat_transition_state.emit(WeaponEnums.WeaponState.COOLDOWN)


func _attack() -> void:
	# Get targets for the given area in the attack area. 
	var targets : Array[Node] = weapon_node.hit_targets_this_swing
	for target in targets:
		if target is ChickenPlayer or target is Enemy:
			SignalManager.weapon_hit_target.emit(target, entity_stats.calc_scaled_damage(weapon_node.current_weapon.damage), DamageEnums.DamageTypes.NORMAL)
			weapon_node.attacking = false
		elif target != null:
			print("Hit target is not a valid target!" + target.name)
			return
