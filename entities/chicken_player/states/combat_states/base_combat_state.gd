class_name BaseCombatState
extends BaseState

@export var ANIMATION_NAME: String

var root_actor: CharacterBody3D
var weapon: MeleeWeapon

func setup(_weapon_node: MeleeWeapon, weapon_root_actor: CharacterBody3D) -> void:
	if not _weapon_node:
		print("Weapon does not exist! Please provide a valid weapon node.")
		return
	weapon = _weapon_node
	root_actor = weapon_root_actor

func enter(_previous_state, _information: Dictionary[String, float] = {}) -> void:
	pass
