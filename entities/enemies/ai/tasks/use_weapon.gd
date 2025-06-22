@tool
extends BTAction

## If true, can be used regardless of the cooldown state of a weapon.
@export var ignore_cooldown: bool = false
## The initial state of the weapon.
@export var start_state: WeaponEnums.WeaponState = WeaponEnums.WeaponState.WINDUP


func _generate_name() -> String:
	var cooldown_str: String = " (Ignoring Cooldown)" if ignore_cooldown else ""

	return "Use Weapon: %s%s" % [
		WeaponEnums.weapon_state_to_string(start_state),
		cooldown_str,
	]


func _enter():
	agent.enemy_weapon_controller.use_weapon(
		ignore_cooldown,
		start_state,
	)


func _tick(_delta: float) -> Status:
	var result: WeaponEnums.WeaponState = agent.enemy_weapon_controller.get_current_weapon_state()

	if start_state == result:
		# If the weapon is already in the desired state, we can return immediately.
		return RUNNING

	match result:
		# RUNNING: The weapon is actively in an attack phase (windup or attacking).
		# The action is "in progress" and should continue on the next tick.
		WeaponEnums.WeaponState.WINDUP, WeaponEnums.WeaponState.ATTACKING:
			return RUNNING

		# FAILURE: The action could not be performed.
		# This happens if the weapon is on cooldown (and we're not ignoring it)
		# or if a fundamental error occurred (e.g., no weapon equipped).
		WeaponEnums.WeaponState.COOLDOWN:
			return SUCCESS

		# FAILURE: The action failed to start or complete.
		_:
			return FAILURE
