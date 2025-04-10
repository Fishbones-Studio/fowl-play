## IdleState: The weapon is idle and waiting for input.
class_name IdleState
extends BaseCombatState

# Constants
# Defines this state as IDLE
const STATE_TYPE: int = WeaponEnums.WeaponState.IDLE

var hit_area: Area3D
var valid_attack : bool = false


# Set up the weapon and cache important nodes
func setup(weapon_node: MeleeWeapon, root_actor: CharacterBody3D) -> void:
	super(weapon_node, root_actor)
	hit_area = weapon_node.hit_area


# This is only excecuted if the root actor is an enemy.
# This looks for the player within the weapon's attack area and then transitions to windup like player.
func process(delta: float) -> void:
	var targets: Array[Node3D] = hit_area.get_overlapping_bodies()
	for target in targets:
		if(target == GameManager.chicken_player):
			valid_attack = true
		else:
			valid_attack = false
	if(valid_attack):
		SignalManager.combat_transition_state.emit(root_actor, WeaponEnums.WeaponState.WINDUP)


# Checks for player input (attack button press)
func input(event: InputEvent) -> void:
	
	if event.is_action_pressed("attack"):
		# Switch to the WINDUP state when attacking
		SignalManager.combat_transition_state.emit(root_actor, WeaponEnums.WeaponState.WINDUP)
