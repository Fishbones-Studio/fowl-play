class_name EnemyWeaponController
extends Node3D

var _current_weapon_slot: int = 0
var _weapon_equiped: bool = false
var _cooldown: float = 0.0


func _ready() -> void:
	_equip_weapons()


func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta


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


func use_weapon() -> void:
	if not _weapon_equiped:
		push_warning(owner.name, " has no weapon equpped.")
		return

	var active_weapon: Node3D = get_child(_current_weapon_slot)

	if active_weapon is MeleeWeaponNode:
		if _cooldown > 0.0:
			push_warning(owner.name, ": weapon on cooldown")
			return

		active_weapon.melee_state_machine._transition_to_next_state(WeaponEnums.WeaponState.WINDUP)
		_cooldown = active_weapon.current_weapon.current_weapon.cooldown_time

	elif active_weapon is RangedWeaponNode:
		pass
