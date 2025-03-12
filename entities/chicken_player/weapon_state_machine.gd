extends Node3D
class_name WeaponStateMachine

var current_weapon: WeaponResource
var current_weapon_instance: Node3D


@export var weapon_slot: Node3D 


func equip_weapon(weapon_resource: WeaponResource):
	if current_weapon_instance:
		current_weapon_instance.queue_free() 

	current_weapon = weapon_resource

  
	if weapon_resource.model:
		current_weapon_instance = weapon_resource.model.instantiate()
		weapon_slot.add_child(current_weapon_instance)

	print("Equipped:", current_weapon.name)


func get_current_weapon_stats() -> WeaponResource:
	return current_weapon
