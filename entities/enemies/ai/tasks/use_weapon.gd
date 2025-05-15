@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"
## If true, can be used regardless of the cooldown state of a weapon.
@export var ignore_cooldown: bool = false
## The initial state of the weapon.
@export var start_state: WeaponEnums.WeaponState = WeaponEnums.WeaponState.WINDUP


func _generate_name() -> String:
	return "Use weapon ➜ %s" % [LimboUtility.decorate_var(target_var)]


func _tick(_delta: float) -> Status:
	match agent.enemy_weapon_controller.use_weapon(ignore_cooldown, start_state):
		0:
			return FAILURE
		1:
			return SUCCESS
		2:
			return RUNNING
		_:
			return FAILURE
