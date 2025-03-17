## WeaponResource: Defines weapon properties that can be used across different weapons.
extends BaseResource
class_name WeaponResource

## Weapon Attributes
@export var damage: int

## Timing Variables
@export var windup_time: float 
@export var attack_duration: float 
@export var cooldown_time: float 

## Visual & UI Elements
@export var model: PackedScene

func _init() -> void:
	type = ItemEnums.ItemTypes.WEAPON
