extends BaseRangedCombatState

var _cooldown_timer: float = 0.0

func enter(_previous_state, _info: Dictionary = {}) -> void:
	SignalManager.cooldown_item_slot.emit(weapon.current_weapon, weapon.current_weapon.attack_duration, true)
	_cooldown_timer = 0.0

func physics_process(delta: float) -> void:
	_cooldown_timer += delta
	if _cooldown_timer >= weapon.current_weapon.cooldown_time:
		transition_signal.emit(
			WeaponEnums.WeaponState.IDLE, 
			{}
		)
