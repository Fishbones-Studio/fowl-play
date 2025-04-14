## IdleState: The weapon is idle and waiting for input.
class_name IdleState
extends BaseCombatState

# Constants
# Defines this state as IDLE
const STATE_TYPE: int = WeaponEnums.WeaponState.IDLE

var hit_area: Area3D
var valid_attack : bool = false


# Set up the weapon and cache important nodes
func setup(_weapon_node: MeleeWeapon, _melee_combat_transition_state: Signal) -> void:
	super(_weapon_node, _melee_combat_transition_state)
	hit_area = _weapon_node.hit_area
	
