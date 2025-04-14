extends Node3D

var current_weapon_index := 0
var active_weapon: Node3D

func _ready() -> void:
	_activate_weapon(current_weapon_index)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_weapon"):
		current_weapon_index = (current_weapon_index + 1) % get_child_count()
		_activate_weapon(current_weapon_index)
	
	if event.is_action_pressed("attack"):
		_start_attack()
	elif event.is_action_released("attack"):
		_stop_attack()

func _activate_weapon(index: int) -> void:
	# Deactivate current weapon
	if active_weapon:
		active_weapon.visible = false
		if active_weapon is RangedWeaponPlayerSlot:
			active_weapon.ranged_weapon_player_controller.stop_firing()
	
	# Activate new weapon
	active_weapon = get_children()[index]
	active_weapon.visible = true
	print("Switched to weapon: ", active_weapon.name)

func _start_attack() -> void:
	if active_weapon is RangedWeaponPlayerSlot:
		active_weapon.ranged_weapon_player_controller.start_firing()
	elif active_weapon is MeleeWeaponPlayerSlot:
		active_weapon.melee_weapon_node.melee_state_machine\
			.melee_combat_transition_state.emit(WeaponEnums.WeaponState.WINDUP, {})

func _stop_attack() -> void:
	if active_weapon is RangedWeaponPlayerSlot:
		active_weapon.ranged_weapon_player_controller.stop_firing()
