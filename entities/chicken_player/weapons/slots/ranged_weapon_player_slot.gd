## Required to be child of PlayerWeaponController
class_name RangedWeaponPlayerSlot 
extends Node3D

@onready var ranged_weapon_node : RangedWeaponNode = $CurrentRangedWeapon
@onready var ranged_weapon_player_controller : RangedWeaponPlayerController = $RangedWeaponPlayerController


func _ready() -> void:
	var ranged_weapon : RangedWeaponResource = Inventory.inventory_data.ranged_weapon_slot
	
	if ranged_weapon == null:
		push_warning("No player ranged_weapon")
		queue_free()
		return

	ranged_weapon_node.ranged_weapon_scene = load(ranged_weapon.model_uid)

	ranged_weapon_node.setup()
	ranged_weapon_player_controller.setup(ranged_weapon_node.current_weapon)
