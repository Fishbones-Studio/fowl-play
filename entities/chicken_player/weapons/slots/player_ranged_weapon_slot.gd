extends Node3D

@onready var ranged_weapon_node : RangedWeaponNode = $CurrentRangedWeapon


func _ready() -> void:
	var ranged_weapon : RangedWeaponResource = Inventory.inventory_data.ranged_weapon_slot
	
	if ranged_weapon == null:
		# TODO: proper empty slot handling
		push_error("No player ranged_weapon")
		queue_free()
	
	ranged_weapon_node.ranged_weapon_scene = load(ranged_weapon.model_uid)
	
	ranged_weapon_node.setup()
