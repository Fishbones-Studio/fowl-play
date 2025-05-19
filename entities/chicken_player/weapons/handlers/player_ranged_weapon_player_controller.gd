class_name RangedWeaponPlayerController 
extends Node

@export var current_weapon : RangedWeapon


func setup(_weapon : RangedWeapon) -> void:
	current_weapon = _weapon


func start_firing() -> void:
	if not is_instance_valid(current_weapon):
		push_warning("No valid ranged weapon equipped")
		return

	if current_weapon.handler:
		current_weapon.handler.start_use()


func stop_firing() -> void:
	if not is_instance_valid(current_weapon):
		return

	if current_weapon.handler:
		current_weapon.handler.end_use()
