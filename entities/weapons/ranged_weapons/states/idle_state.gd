class_name RangedIdleState 
extends BaseRangedCombatState


func _init()-> void:
	if animation_name.is_empty():
		animation_name = "Idle"
