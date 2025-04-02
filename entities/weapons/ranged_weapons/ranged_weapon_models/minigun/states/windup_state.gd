extends BaseRangedCombatState

var _windup_timer: float = 0.0

func enter(_previous_state, _info: Dictionary = {}) -> void:
	print("winding up")
	_windup_timer = 0.0

func process(delta: float) -> void:
	_windup_timer += delta
	
	if _windup_timer >= weapon.current_weapon.windup_time:
		print("going to attack")
		transition_signal.emit(WeaponEnums.WeaponState.ATTACKING, {})
