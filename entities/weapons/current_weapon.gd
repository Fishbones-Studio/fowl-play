## Weapon State Machine: Manages weapon state transitions and behavior.
@tool
class_name CurrentWeapon extends Node3D

## Exported Variables
@export_group("weapon")
@export var weapon_scene: PackedScene:
	set(value):
		# Custom setter to validate the scene type
		if value and value.can_instantiate() and value.instantiate() is Weapon:
			weapon_scene = value
		else:
			push_error("Assigned scene is not a valid Weapon type")
			weapon_scene = null

var current_weapon: Weapon


func _ready() -> void:
	if not weapon_scene:
		push_error("No valid weapon scene assigned!")
		return
	
	current_weapon = weapon_scene.instantiate() as Weapon
	print("set weapon")
	if not current_weapon:
		push_error("Failed to instantiate weapon!")
		return
	
	add_child(current_weapon)
