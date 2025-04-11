extends Node

# TODO: setup method. current_weapon will be null

@onready var current_weapon : RangedWeapon = $"../CurrentRangedWeapon".current_weapon

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_secondary"):
		_start_firing()
	elif event.is_action_released("attack_secondary"):
		_stop_firing()

func _start_firing() -> void:
	if not is_instance_valid(current_weapon):
		push_warning("No valid ranged weapon equipped")
		return

	if current_weapon.handler:
		current_weapon.handler.start_use()

func _stop_firing() -> void:
	if not is_instance_valid(current_weapon):
		return

	if current_weapon.handler:
		current_weapon.handler.end_use()
