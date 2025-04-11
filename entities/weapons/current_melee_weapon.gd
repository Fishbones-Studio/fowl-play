## Weapon State Machine: Manages weapon state transitions and behavior.
class_name CurrentWeapon
extends Node3D

var current_weapon: MeleeWeapon


func _ready() -> void:
	var melee_weapon : MeleeWeaponResource = Inventory.inventory_data.melee_weapon_slot
	var weapon_scene = load(melee_weapon.model_uid)

	if not weapon_scene:
		push_error("No valid weapon scene assigned!")
		return

	current_weapon = weapon_scene.instantiate() as MeleeWeapon
	
	if not current_weapon:
		push_error("Failed to instantiate weapon!")
		return

	add_child(current_weapon)
