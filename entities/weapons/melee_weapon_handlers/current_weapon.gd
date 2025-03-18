## Weapon State Machine: Manages weapon state transitions and behavior.
extends Node3D

## Exported Variables
@export_group("weapon")
@export var current_weapon: WeaponResource

## Public Variables
var current_weapon_instance: Node3D

## Onready Variables
@export var hitbox: Area3D


func _ready():
	if not current_weapon:
		push_error("No weapon assigned!")
		return

	equip_weapon(current_weapon)


func equip_weapon(weapon_resource: WeaponResource):
	if current_weapon_instance:
		current_weapon_instance.queue_free()

	current_weapon = weapon_resource

	if weapon_resource.model:
		current_weapon_instance = weapon_resource.model.instantiate()
		add_child(current_weapon_instance)
