## Handles input for the player weapons
extends Node3D

var current_weapon_index := 0
var active_weapon: Node3D

func _ready() -> void:
	print("Amount of weapons: %d"  % get_child_count())
	_swap_weapoon(current_weapon_index)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_weapon"):
		_swap_weapoon(current_weapon_index)
	
	if event.is_action_pressed("attack"):
		_start_attack()
	elif event.is_action_released("attack"):
		_stop_attack()

func _swap_weapoon(prev_index: int) -> void:
	var children : int = get_child_count()
	
	if children <= 0:
		push_warning("No weapon children")
		queue_free()
		return
	elif children > 1:
		current_weapon_index = (current_weapon_index + 1) % children
		
		# Deactivate current weapon
		if active_weapon:
			active_weapon.visible = false
			if active_weapon is RangedWeaponPlayerSlot:
				active_weapon.ranged_weapon_player_controller.stop_firing()
		
		# Activate new weapon
		active_weapon = get_children()[current_weapon_index]
		active_weapon.visible = true
		print("Switched to weapon: ", active_weapon.name)

func _start_attack() -> void:
	if not active_weapon: return
	if active_weapon is RangedWeaponPlayerSlot:
		active_weapon.ranged_weapon_player_controller.start_firing()
	elif active_weapon is MeleeWeaponPlayerSlot:
		active_weapon.melee_weapon_node.melee_state_machine\
			.melee_combat_transition_state.emit(WeaponEnums.WeaponState.WINDUP, {})

func _stop_attack() -> void:
	if not active_weapon: return
	if active_weapon is RangedWeaponPlayerSlot:
		active_weapon.ranged_weapon_player_controller.stop_firing()
