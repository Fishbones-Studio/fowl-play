class_name EnemyWeaponController
extends Node3D

enum WeaponSlot { MELEE = 0, RANGED = 1 }

@export var enable_stun: bool = false

var _current_weapon_slot: WeaponSlot = WeaponSlot.MELEE
var _equipped_weapons: Array[bool] = [false, false] # Track which slots have weapons

func _ready() -> void:
	_equip_weapons()

func _equip_weapons() -> void:
	# Equip ALL available weapons
	for weapon_handler in get_children():
		if (
		weapon_handler is MeleeWeaponNode
		and weapon_handler.melee_weapon_scene
		):
			_equip_weapon(weapon_handler, WeaponSlot.MELEE)
		elif (
		weapon_handler is RangedWeaponNode
		and weapon_handler.current_weapon
		):
			_equip_weapon(weapon_handler, WeaponSlot.RANGED)

	# Default to melee if available, otherwise ranged
	if _equipped_weapons[WeaponSlot.MELEE]:
		_current_weapon_slot = WeaponSlot.MELEE
	elif _equipped_weapons[WeaponSlot.RANGED]:
		_current_weapon_slot = WeaponSlot.RANGED

	_update_weapon_visibility()

func _equip_weapon(weapon_handler: Node3D, slot: WeaponSlot) -> void:
	if weapon_handler is MeleeWeaponNode:
		weapon_handler.current_weapon.enable_stun = enable_stun
	_equipped_weapons[slot] = true

func _update_weapon_visibility() -> void:
	for i in range(get_child_count()):
		get_child(i).visible = (
		i == _current_weapon_slot and _equipped_weapons[i]
		)

func swap_weapon() -> bool:
	if not (
	_equipped_weapons[WeaponSlot.MELEE]
	and _equipped_weapons[WeaponSlot.RANGED]
	):
		push_warning(
			"%s cannot swap weapons - not all weapons are equipped." % owner.name
		)
		return false

	# Toggle between melee and ranged
	_current_weapon_slot = (
	WeaponSlot.RANGED
	if _current_weapon_slot == WeaponSlot.MELEE
	else WeaponSlot.MELEE
	)
	_update_weapon_visibility()
	return true

func use_weapon(
	ignore_cooldown: bool = false,
	start_state: WeaponEnums.WeaponState = WeaponEnums.WeaponState.WINDUP
) -> WeaponEnums.WeaponState:
	if not _equipped_weapons[_current_weapon_slot]:
		push_warning("%s has no weapon equipped in current slot." % owner.name)
		return WeaponEnums.WeaponState.ERROR

	var state_machine: Node = _get_current_state_machine()
	if not state_machine:
		return WeaponEnums.WeaponState.ERROR
		
	# Add a check to prevent transitioning to the same state.
	if state_machine.current_state.state_type == start_state:
		# Already in the desired state, just report success.
		return start_state

	# Special handling for WINDUP state (attack initiation)
	if start_state == WeaponEnums.WeaponState.WINDUP:
		return _handle_windup_request(state_machine, ignore_cooldown)

	# For other states, directly transition
	state_machine._transition_to_next_state(start_state)
	return start_state

func _get_current_state_machine() -> Node:
	var active_weapon: Node = get_child(_current_weapon_slot)

	if active_weapon is MeleeWeaponNode:
		return active_weapon.melee_state_machine
	elif active_weapon is RangedWeaponNode:
		return active_weapon.current_weapon.handler.state_machine

	return null

func _handle_windup_request(
	state_machine, ignore_cooldown: bool
) -> WeaponEnums.WeaponState:
	var current_state = state_machine.current_state
	var cooldown_state = state_machine.states.get(
		WeaponEnums.WeaponState.COOLDOWN
	)
	var attacking_state = state_machine.states.get(
		WeaponEnums.WeaponState.ATTACKING
	)
	var windup_state = state_machine.states.get(
		WeaponEnums.WeaponState.WINDUP
	)

	# Check for blocking conditions
	if current_state == cooldown_state and not ignore_cooldown:
		return WeaponEnums.WeaponState.COOLDOWN
	if current_state == attacking_state and not ignore_cooldown:
		return WeaponEnums.WeaponState.ATTACKING
	if current_state == windup_state:
		return WeaponEnums.WeaponState.WINDUP # Already winding up

	# Clear to start windup
	state_machine._transition_to_next_state(WeaponEnums.WeaponState.WINDUP)
	return WeaponEnums.WeaponState.WINDUP

func has_weapon_equipped() -> bool:
	return _equipped_weapons[_current_weapon_slot]

func get_current_weapon_state() -> WeaponEnums.WeaponState:
	if not has_weapon_equipped():
		return WeaponEnums.WeaponState.ERROR

	var state_machine: Node = _get_current_state_machine()
	if not state_machine or not state_machine.current_state:
		return WeaponEnums.WeaponState.ERROR

	# Assumes each state has a state_type property
	return state_machine.current_state.state_type
