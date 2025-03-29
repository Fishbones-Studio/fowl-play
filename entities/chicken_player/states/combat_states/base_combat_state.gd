class_name BaseCombatState
extends BaseState

@export var ANIMATION_NAME: String

var weapon: MeleeWeapon


func setup(_weapon_node: MeleeWeapon) -> void:
	print(_weapon_node)
	weapon = _weapon_node


func enter(_previous_state, _information: Dictionary[String, float] = {}) -> void:
	pass
