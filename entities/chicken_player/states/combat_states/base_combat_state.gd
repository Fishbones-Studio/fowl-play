class_name BaseCombatState
extends BaseState

@export var ANIMATION_NAME: String

var weapon: MeleeWeapon


func setup(_weapon_node: MeleeWeapon) -> void:
	if not _weapon_node:
		print("Weapon does not exist! Please provide a valid weapon node.")
		return
	weapon = _weapon_node


func enter(_previous_state, _information: Dictionary[String, float] = {}) -> void:
	pass
