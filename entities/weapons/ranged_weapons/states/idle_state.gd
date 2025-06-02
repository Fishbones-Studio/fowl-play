class_name RangedIdleState 
extends BaseRangedCombatState


func _init()-> void:
	state_type = WeaponEnums.WeaponState.IDLE
	if animation_name.is_empty():
		animation_name = "Idle"
