class_name BaseRangedCombatState
extends BaseState

@export var ANIMATION_NAME: String
@export var state_type: WeaponEnums.WeaponState

var weapon: RangedWeapon
var transition_signal : Signal


func setup(_weapon_node: RangedWeapon, _transition_signal : Signal) -> void:
	if not _weapon_node:
		print("Weapon does not exist! Please provide a valid weapon node.")
		return
	
	if not _transition_signal:
		print("Transition signal does not exist! Please provide a valid signal.")
		return
	
	weapon = _weapon_node
	transition_signal = _transition_signal


func enter(_previous_state, _information: Dictionary = {}) -> void:
	pass

	# TODO fix
func process_hit(result: Dictionary) -> void:
	var target = result.collider
	print(target)
	if target is PhysicsBody3D:
		SignalManager.weapon_hit_area_body_entered.emit(target)
