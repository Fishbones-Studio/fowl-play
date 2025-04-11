## Weapon State Machine: Manages weapon state transitions and behavior.
@tool
class_name RangedWeaponNode
extends Node3D

## Exported Variables
@export_group("weapon")
@export var ranged_weapon_scene: PackedScene:
	set(value):
		# Custom setter to validate the scene type
		if value and value.can_instantiate() and value.instantiate() is RangedWeapon:
			ranged_weapon_scene = value
		else:
			push_error("Assigned scene is not a valid Weapon type")
			ranged_weapon_scene = null

var current_weapon: RangedWeapon

func _ready() -> void:
	if ranged_weapon_scene:
		setup()

func setup() -> void:
	if not ranged_weapon_scene:
		push_error("No valid weapon scene assigned!")
		return

	current_weapon = ranged_weapon_scene.instantiate() as RangedWeapon
	if not current_weapon:
		push_error("Failed to instantiate weapon!")
		return

	add_child(current_weapon)
