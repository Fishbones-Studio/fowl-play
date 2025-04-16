## Weapon State Machine: Manages weapon state transitions and behavior.
@tool
class_name RangedWeaponNode
extends Node3D

## Exported Variables
@export_group("weapon")
@export var ranged_weapon_scene: PackedScene:
	set(value):
		if value == null: 
			ranged_weapon_scene = null
			current_weapon = null
			return
		# Custom setter to validate the scene type
		var temp_weapon_instance = value.instantiate()
		if value and value.can_instantiate() and temp_weapon_instance is RangedWeapon:
			current_weapon = temp_weapon_instance
			ranged_weapon_scene = value
		else:
			push_error("Assigned scene is not a valid Weapon type")
			ranged_weapon_scene = null

var current_weapon: RangedWeapon

func _ready() -> void:
	if ranged_weapon_scene || get_parent() is Enemy:
		setup()

func setup() -> void:
	if not ranged_weapon_scene:
		push_error("No valid weapon scene assigned!")
		return

	if not current_weapon:
		current_weapon = ranged_weapon_scene.instantiate() as RangedWeapon
	if not current_weapon:
		push_error("Failed to instantiate ranged weapon!")
		return

	add_child(current_weapon)
