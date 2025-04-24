## Handles input transitions for ranged weapon state machine
class_name RangedWeaponHandler 
extends Node

@export var state_machine: RangedWeaponStateMachine


## Called when attack action is initiated (button pressed)
func start_use() -> void:
	match state_machine.current_state.state_type:
		WeaponEnums.WeaponState.COOLDOWN:
			print("Attack not allowed during cooldown")
			return
		WeaponEnums.WeaponState.IDLE:
			state_machine.combat_transition_state.emit(WeaponEnums.WeaponState.WINDUP, {})
		WeaponEnums.WeaponState.ATTACKING:
			# Allow continuous fire if weapon supports it
			if weapon_supports_hold_fire():
				pass
			else: 
				print("Cannot attack again during attack")
		_:
			pass


## Called when attack action is released (button released)
func end_use() -> void:
	print("Stopping weapon")
	match state_machine.current_state.state_type:
		WeaponEnums.WeaponState.WINDUP:
			# Cancel windup if released early
			state_machine.combat_transition_state.emit(WeaponEnums.WeaponState.IDLE, {})
		WeaponEnums.WeaponState.ATTACKING:
			# Cancel attack if released early
			if weapon_supports_early_release():
				state_machine.combat_transition_state.emit(WeaponEnums.WeaponState.COOLDOWN, {})
		_:
			pass


## Helper to check weapon's hold capability
func weapon_supports_hold_fire() -> bool:
	return state_machine.weapon.current_weapon.allow_continuous_fire


## Helper to check if weapon allows early release
func weapon_supports_early_release() -> bool:
	return state_machine.weapon.current_weapon.allow_early_release
