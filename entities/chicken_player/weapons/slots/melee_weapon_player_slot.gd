## Required to be child of PlayerWeaponController
class_name MeleeWeaponPlayerSlot 
extends Node3D

@onready var melee_weapon_node : MeleeWeaponNode = $MeleeWeapon


func _ready() -> void:
	var melee_weapon : MeleeWeaponResource = Inventory.inventory_data.melee_weapon_slot
	
	if melee_weapon == null:
		push_warning("No player melee_weapon")
		queue_free()
		return
	
	melee_weapon_node.melee_weapon_scene = load(melee_weapon.model_uid)
	melee_weapon_node.weapon_collision_mask = get_parent().weapon_collision_mask
	
	melee_weapon_node.setup()
