class_name BaseRangedCombatState
extends BaseState

@export var ANIMATION_NAME: String
@export var state_type: WeaponEnums.WeaponState

var weapon: RangedWeapon
var transition_signal : Signal
var origin_entity : PhysicsBody3D ## The entity that is using the weapon


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
	
func process_hit(result: Dictionary) -> void:
	var target = result.collider
	print("Colliding with:" + result.collider)
	if target is PhysicsBody3D:
		if target == origin_entity:
			print("Hit self")
			return
		print("Hit physicsbody")
		SignalManager.weapon_hit_target.emit(target, weapon.current_weapon.damage)
