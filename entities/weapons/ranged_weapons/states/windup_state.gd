class_name WindupIdleState extends BaseRangedCombatState

var _windup_timer: float = 0.0


func enter(_previous_state, _info: Dictionary = {}) -> void:
	_windup_timer = 0.0


func process(delta: float) -> void:
	_windup_timer += delta
	
	if _windup_timer >= weapon.current_weapon.windup_time:
		transition_signal.emit(WeaponEnums.WeaponState.ATTACKING, {})
