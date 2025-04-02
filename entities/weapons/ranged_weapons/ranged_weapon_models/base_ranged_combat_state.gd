class_name BaseRangedCombatState
extends BaseState

@export var ANIMATION_NAME: String

var weapon: RangedWeapon


func setup(_weapon_node: RangedWeapon) -> void:
	if not _weapon_node:
		print("Weapon does not exist! Please provide a valid weapon node.")
		return
	weapon = _weapon_node


func enter(_previous_state, _information: Dictionary[String, float] = {}) -> void:
	pass

func process_hit(result: Dictionary) -> void:
	var target = result.collider
	if target is PhysicsBody3D:
		SignalManager.weapon_hit_area_body_entered.emit(target)
