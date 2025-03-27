class_name BaseCombatState
extends BaseState

@export var ANIMATION_NAME: String

var weapon: Weapon


func setup(_weapon_node: Weapon) -> void:
	weapon = _weapon_node


func enter(_previous_state, _information: Dictionary[String, float] = {}) -> void:
	pass
