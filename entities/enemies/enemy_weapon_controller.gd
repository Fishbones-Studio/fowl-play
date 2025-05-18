class_name EnemyWeaponController
extends Node3D

var _current_weapon_slot: int = 0
var _weapon_equiped: bool = false


func _ready() -> void:
	_equip_weapons()


func _equip_weapons() -> void:
	for weapon_handler in get_children():
		if weapon_handler is MeleeWeaponNode:
			if weapon_handler.melee_weapon_scene:
				weapon_handler.visible = true
				_current_weapon_slot = 0
				_weapon_equiped = true
				return
		elif weapon_handler is RangedWeaponNode:
			if weapon_handler.current_weapon:
				weapon_handler.visible = true
				_current_weapon_slot = 1
				_weapon_equiped = true
				return


func swap_weapon() -> void:
	if not _weapon_equiped:
		push_warning(owner.name, " has no weapon equpped.")
		return

	# Validate weapons, cannot swap weapon is one of them does not exist
	for weapon_handler in get_children():
		if weapon_handler is MeleeWeaponNode:
			if not weapon_handler.melee_weapon_scene:
				return
		elif weapon_handler is RangedWeaponNode:
			if not weapon_handler.current_weapon:
				return

	# Hide current weapon
	get_child(_current_weapon_slot).visible = false

	# Toggle slot
	_current_weapon_slot ^= 1

	# Show new weapon
	get_child(_current_weapon_slot).visible = true


func use_weapon(ignore_cooldown: bool = false, start_state: WeaponEnums.WeaponState = WeaponEnums.WeaponState.WINDUP) -> int:
	if not _weapon_equiped:
		push_warning(owner.name, " has no weapon equpped.")
		return 0

	var active_weapon: Node3D = get_child(_current_weapon_slot)

	if active_weapon is MeleeWeaponNode:
		var current_state: BaseCombatState = active_weapon.melee_state_machine.current_state
		var cooldown_state: BaseCombatState = active_weapon.melee_state_machine.states[WeaponEnums.WeaponState.COOLDOWN]
		var attacking_state: BaseCombatState = active_weapon.melee_state_machine.states[WeaponEnums.WeaponState.ATTACKING]
		var windup_state: BaseCombatState = active_weapon.melee_state_machine.states[WeaponEnums.WeaponState.WINDUP]

		match start_state:
			WeaponEnums.WeaponState.WINDUP:
				if current_state == cooldown_state and not ignore_cooldown:
					return 0
				if current_state == windup_state:
					return 2
				if current_state == attacking_state and not ignore_cooldown:
					return 2
				active_weapon.melee_state_machine._transition_to_next_state(WeaponEnums.WeaponState.WINDUP)
				return 1
			WeaponEnums.WeaponState.IDLE:
				active_weapon.melee_state_machine._transition_to_next_state(WeaponEnums.WeaponState.IDLE)
				return 1
			WeaponEnums.WeaponState.COOLDOWN:
				active_weapon.melee_state_machine._transition_to_next_state(WeaponEnums.WeaponState.COOLDOWN)
				return 1

	elif active_weapon is RangedWeaponNode:
		active_weapon.current_weapon.handler.start_use()
		return 1

	return 0
