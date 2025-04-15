extends Node3D

@export_flags_3d_physics var weapon_collision_mask: int

var current_weapon_index: int = 0
var active_weapon: Node3D = null
var valid_weapons: Array[Node3D] = []



func _ready() -> void:
	# Initialize the weapon state
	call_deferred("_update_weapon_state")



func _input(event: InputEvent) -> void:
	if not active_weapon:
		return
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


func _update_weapon_state() -> void:
	# Find valid weapons
	valid_weapons = []
	for child in get_children():
		if is_instance_valid(child):
			if child is MeleeWeaponPlayerSlot and is_instance_valid(child.melee_weapon_node) and child.melee_weapon_node.current_weapon:
				valid_weapons.append(child)
			elif child is RangedWeaponPlayerSlot and is_instance_valid(child.ranged_weapon_node) and child.ranged_weapon_node.current_weapon:
				valid_weapons.append(child)

	if valid_weapons.is_empty():
		if is_instance_valid(active_weapon):
			_deactivate_weapon(active_weapon)
		active_weapon = null
		current_weapon_index = -1
		return

	# Deactivate all valid weapons first
	for weapon in valid_weapons:
		SignalManager.deactivate_item_slot.emit(weapon.get_index())
		_deactivate_weapon(weapon)

	# Validate current index
	if current_weapon_index < 0 or current_weapon_index >= valid_weapons.size():
		current_weapon_index = 0

	# Activate new weapon
	active_weapon = valid_weapons[current_weapon_index]
	if is_instance_valid(active_weapon):
		_activate_weapon(active_weapon)
		SignalManager.activate_item_slot.emit(current_weapon_index)



func _swap_weapon() -> void:
	if valid_weapons.size() <= 1:
		return
	current_weapon_index = (current_weapon_index + 1) % valid_weapons.size()
	_update_weapon_state()


func _deactivate_weapon(weapon_node: Node3D) -> void:
	if not is_instance_valid(weapon_node):
		return
	weapon_node.visible = false
	if weapon_node is RangedWeaponPlayerSlot and is_instance_valid(weapon_node.ranged_weapon_player_controller):
		weapon_node.ranged_weapon_player_controller.stop_firing()


func _activate_weapon(weapon_node: Node3D) -> void:
	if not is_instance_valid(weapon_node):
		return
	weapon_node.visible = true



func _start_attack() -> void:
	if not active_weapon:
		return
	if active_weapon is RangedWeaponPlayerSlot and is_instance_valid(active_weapon.ranged_weapon_player_controller):
		active_weapon.ranged_weapon_player_controller.start_firing()
	elif active_weapon is MeleeWeaponPlayerSlot and is_instance_valid(active_weapon.melee_weapon_node) and is_instance_valid(active_weapon.melee_weapon_node.melee_state_machine):
		active_weapon.melee_weapon_node.melee_state_machine.melee_combat_transition_state.emit(WeaponEnums.WeaponState.WINDUP, {})



func _stop_attack() -> void:
	if not active_weapon:
		return
	if active_weapon is RangedWeaponPlayerSlot and is_instance_valid(active_weapon.ranged_weapon_player_controller):
		active_weapon.ranged_weapon_player_controller.stop_firing()
