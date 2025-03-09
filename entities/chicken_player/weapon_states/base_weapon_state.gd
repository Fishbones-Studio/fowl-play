class_name BaseWeaponState
extends BaseState

@export var STATE_TYPE: WeaponEnums.WeaponStates

var weapon: Node
var player: ChickenPlayer
var previous_state: WeaponEnums.WeaponStates

## Base stats for the weapon.
@export var attack_damage: float = 10.0
@export var attack_speed: float = 1.0  
@export var cooldown_duration: float = 0.5  

var attack_timer: float = 0.0


## Called once to set the weapon and player references.
##
## Parameters:
## _weapon references to the weapon node
## _player references to the player node
func setup(_weapon: Node, _player: ChickenPlayer) -> void:
	if _weapon == null:
		push_error(owner.name + ": No weapon reference set for state: " + str(STATE_TYPE))
	if _player == null:
		push_error(owner.name + ": No player reference set for state: " + str(STATE_TYPE))
	weapon = _weapon
	player = _player
	
## Called once when entering the state
##
## Parameters:
## _previous_state: The state that was active before this one.
func enter(_previous_state: WeaponEnums.WeaponStates, _information: Dictionary = {}) -> void:
	previous_state = _previous_state
	


## Handles input events for weapon-specific behavior.
##
## **Must be overridden** in child classes that need input handling.
##
## Parameters:
## _event: Input event to process.
func input(_event: InputEvent) -> void:
	pass
	



## Helper function to calculate attack cooldown based on attack speed.
func get_attack_cooldown() -> float:
	return 1.0 / attack_speed


## Helper function to check if the weapon is ready to attack.
func is_ready_to_attack() -> bool:
	return attack_timer <= 0.0


## Helper function to reset the attack timer.
func reset_attack_timer() -> void:
	attack_timer = get_attack_cooldown()
