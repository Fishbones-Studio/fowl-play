class_name BaseCombatState
extends BaseState

@export var ANIMATION_NAME: String

var melee_combat_transition_state: Signal
var state_type: int
var weapon_node: MeleeWeapon
var entity_stats: LivingEntityStats


func setup(_weapon_node: MeleeWeapon, _melee_combat_transition_state: Signal, _entity_stats: LivingEntityStats) -> void:
	if not _weapon_node:
		push_error("Weapon does not exist! Please provide a valid weapon node.")
		return

	weapon_node = _weapon_node
	melee_combat_transition_state = _melee_combat_transition_state
	entity_stats = _entity_stats


func enter(_previous_state, _information: Dictionary = {}) -> void:
	pass
