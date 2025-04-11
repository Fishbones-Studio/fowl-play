class_name BaseCombatState
extends BaseState

@export var ANIMATION_NAME: String
var melee_combat_transition_state : Signal

var root_actor: CharacterBody3D
var weapon_node: MeleeWeapon

func setup(_weapon_node: MeleeWeapon, _melee_combat_transition_state: Signal, _root_actor: CharacterBody3D) -> void:
	if not _weapon_node:
		print("Weapon does not exist! Please provide a valid weapon node.")
		return
	weapon_node = _weapon_node
	root_actor = _root_actor
	melee_combat_transition_state = _melee_combat_transition_state

func enter(_previous_state, _information: Dictionary = {}) -> void:
	pass
