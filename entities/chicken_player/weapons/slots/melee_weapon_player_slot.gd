extends Node3D

@export var actor : CharacterBody3D

@onready var melee_weapon_node : MeleeWeaponNode = $MeleeWeapon


func _ready() -> void:
	var melee_weapon : MeleeWeaponResource = Inventory.inventory_data.melee_weapon_slot
	
	if melee_weapon == null:
		# TODO: proper empty slot handling
		push_error("No player melee_weapon")
		queue_free()
	
	melee_weapon_node.melee_weapon_scene = load(melee_weapon.model_uid)
	melee_weapon_node.actor = actor
	
	melee_weapon_node.setup()
