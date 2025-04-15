## Handles input for the player weapons
extends Node3D

# Using flags for user-friendly layer selection in the editor
# NOTE: currently only used for melee weapon, might also be used for ranged weapon at later date
@export_flags_3d_physics var weapon_collision_mask: int

var current_weapon_index: int = 0
var active_weapon: Node3D = null

func _ready() -> void:
	var child_count: int = get_child_count()
	print("Amount of weapons: %d" % child_count)
	await owner.ready
	_init_weapon(child_count)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_weapon"):
		_swap_weapon()
	elif event.is_action_pressed("attack"):
		_start_attack()
	elif event.is_action_released("attack"):
		_stop_attack()

func _init_weapon(weapon_count : int) -> void:
	if weapon_count <= 0:
		push_warning("No weapon children")
		queue_free()
		return

	# Deactivate all weapons
	for i in weapon_count:
		SignalManager.deactivate_item_slot.emit(i)
		var weapon: Node = get_child(i)
		weapon.visible = false
		if weapon is RangedWeaponPlayerSlot:
			weapon.ranged_weapon_player_controller.stop_firing()

	# Activate the current weapon
	SignalManager.activate_item_slot.emit(current_weapon_index)
	active_weapon = get_child(current_weapon_index)
	print(active_weapon)
	print("Current weapon index: %d" % current_weapon_index )
	active_weapon.visible = true
	print("Switched to weapon: %s" % active_weapon.name)

func _swap_weapon() -> void:
	var weapon_count: int = get_child_count()
	if weapon_count <= 0:
		push_warning("No weapon children")
		queue_free()
		return
	if weapon_count == 1:
		return

	current_weapon_index = (current_weapon_index + 1) % weapon_count
	_init_weapon(weapon_count)

func _start_attack() -> void:
	if not active_weapon:
		return
	if active_weapon is RangedWeaponPlayerSlot:
		active_weapon.ranged_weapon_player_controller.start_firing()
	elif active_weapon is MeleeWeaponPlayerSlot:
		active_weapon.melee_weapon_node.melee_state_machine.melee_combat_transition_state.emit(
			WeaponEnums.WeaponState.WINDUP, {}
		)

func _stop_attack() -> void:
	if not active_weapon:
		return
	if active_weapon is RangedWeaponPlayerSlot:
		active_weapon.ranged_weapon_player_controller.stop_firing()
