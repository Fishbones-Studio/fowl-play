## Weapon State Machine: Manages weapon state transitions and behavior.
extends Node3D

## Exported Variables
@export var current_weapon: WeaponResource

## Public Variables
var current_weapon_instance: Node3D


## Onready Variables
@onready var hitbox: Area3D = $"../HitArea"


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
	elif weapon_resource:
		current_weapon_instance = weapon_resource.instantiate()
		add_child(current_weapon_instance)
