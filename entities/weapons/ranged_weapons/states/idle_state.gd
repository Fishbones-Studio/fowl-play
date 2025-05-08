class_name RangedIdleState extends BaseRangedCombatState

func _init()-> void:
	state_type = WeaponEnums.WeaponState.IDLE
	if ANIMATION_NAME.is_empty():
		ANIMATION_NAME = "Idle"
