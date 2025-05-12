extends Node3D

@export_flags_3d_physics var weapon_collision_mask: int

var current_weapon_index: int            = -1
var active_weapon_slot: Node3D           = null
var active_weapon_resource: BaseResource = null
var valid_weapon_slots: Array[Node3D]    = []

@onready var melee_weapon_slot : MeleeWeaponPlayerSlot = $MeleeWeaponPlayerSlot
@onready var ranged_weapon_slot : RangedWeaponPlayerSlot = $RangedWeaponPlayerSlot


func _ready() -> void:
	# Initialize the weapon state
	call_deferred("_update_weapon_state")
	GameManager.chicken_player_set.connect(_on_chicken_player_set)


func _input(event: InputEvent) -> void:
	if UIManager.game_input_blocked: return
	if not is_instance_valid(active_weapon_slot):
		return

	if event.is_action_pressed("switch_weapon"):
		_swap_weapon()
	elif event.is_action_pressed("attack"):
		_start_attack()
	elif event.is_action_released("attack"):
		_stop_attack()


func _on_chicken_player_set() -> void:
	# Init the weapons
	if is_instance_valid(melee_weapon_slot):
		melee_weapon_slot.setup()
	if is_instance_valid(ranged_weapon_slot):
		ranged_weapon_slot.setup()


func _update_weapon_state() -> void:
	var previously_active_slot: Node3D = active_weapon_slot
	valid_weapon_slots.clear()

	for child in get_children():
		if not is_instance_valid(child):
			continue

		if child is MeleeWeaponPlayerSlot and is_instance_valid(child.melee_weapon_node) and child.melee_weapon_node.current_weapon:
			valid_weapon_slots.append(child)
		elif child is RangedWeaponPlayerSlot and is_instance_valid(child.ranged_weapon_node) and child.ranged_weapon_node.current_weapon:
			valid_weapon_slots.append(child)

	if valid_weapon_slots.is_empty():
		if is_instance_valid(previously_active_slot):
			_deactivate_weapon(previously_active_slot)
		active_weapon_slot = null
		active_weapon_resource = null
		current_weapon_index = -1
		return

	# Deactivate all valid weapons first
	for weapon_slot in valid_weapon_slots:
		_deactivate_weapon(weapon_slot)

	# Validate current index
	if current_weapon_index < 0 or current_weapon_index >= valid_weapon_slots.size():
		var previous_index: int = valid_weapon_slots.find(previously_active_slot)
		current_weapon_index = previous_index if previous_index != -1 else 0

	# Activate new weapon
	active_weapon_slot = valid_weapon_slots[current_weapon_index]
	if is_instance_valid(active_weapon_slot):
		active_weapon_resource = _get_weapon_resource(active_weapon_slot)
		_activate_weapon(active_weapon_slot)
		if active_weapon_resource:
			print("activating weapon slot: ", active_weapon_resource.name)
			SignalManager.activate_item_slot.emit(active_weapon_resource)
	else:
		push_warning("Selected weapon slot became invalid unexpectedly.")
		active_weapon_slot = null
		active_weapon_resource = null
		current_weapon_index = -1
		call_deferred("_update_weapon_state")


func _swap_weapon() -> void:
	if valid_weapon_slots.size() <= 1:
		return

	current_weapon_index = (current_weapon_index + 1) % valid_weapon_slots.size()
	_update_weapon_state()


func _deactivate_weapon(weapon_slot: Node3D) -> void:
	if not is_instance_valid(weapon_slot):
		return

	weapon_slot.visible = false
	_try_stop_firing_or_attacking(weapon_slot)

	var resource_to_deactivate: Resource = _get_weapon_resource(weapon_slot)
	if resource_to_deactivate:
		SignalManager.deactivate_item_slot.emit(resource_to_deactivate)


func _activate_weapon(weapon_slot: Node3D) -> void:
	if not is_instance_valid(weapon_slot):
		return
	weapon_slot.visible = true


func _start_attack() -> void:
	if not is_instance_valid(active_weapon_slot):
		return

	if active_weapon_slot is MeleeWeaponPlayerSlot:
		if is_instance_valid(active_weapon_slot.melee_weapon_node) and \
		is_instance_valid(active_weapon_slot.melee_weapon_node.melee_state_machine) and \
		active_weapon_slot.melee_weapon_node.melee_state_machine.current_state.state_type == WeaponEnums.WeaponState.IDLE:
			active_weapon_slot.melee_weapon_node.melee_state_machine.melee_combat_transition_state.emit(WeaponEnums.WeaponState.WINDUP, {})
	elif active_weapon_slot is RangedWeaponPlayerSlot:
		if is_instance_valid(active_weapon_slot.ranged_weapon_player_controller):
			active_weapon_slot.ranged_weapon_player_controller.start_firing()


func _stop_attack() -> void:
	if not is_instance_valid(active_weapon_slot):
		return

	if active_weapon_slot is RangedWeaponPlayerSlot:
		if is_instance_valid(active_weapon_slot.ranged_weapon_player_controller):
			active_weapon_slot.ranged_weapon_player_controller.stop_firing()


func _get_weapon_resource(weapon_slot: Node3D) -> Resource:
	if not is_instance_valid(weapon_slot):
		push_warning("Invalid weapon slot passed to _get_weapon_resource")
		return null

	if weapon_slot is MeleeWeaponPlayerSlot:
		if is_instance_valid(weapon_slot.melee_weapon_node) and is_instance_valid(weapon_slot.melee_weapon_node.current_weapon):
			return weapon_slot.melee_weapon_node.current_weapon.current_weapon
	elif weapon_slot is RangedWeaponPlayerSlot:
		if is_instance_valid(weapon_slot.ranged_weapon_node) and is_instance_valid(weapon_slot.ranged_weapon_node.current_weapon):
			return weapon_slot.ranged_weapon_node.current_weapon.current_weapon

	push_warning("No valid weapon resource found in slot: ", weapon_slot)
	return null


func _try_stop_firing_or_attacking(weapon_slot: Node3D) -> void:
	if not is_instance_valid(weapon_slot):
		return

	if weapon_slot is RangedWeaponPlayerSlot:
		if is_instance_valid(weapon_slot.ranged_weapon_player_controller):
			weapon_slot.ranged_weapon_player_controller.stop_firing()
