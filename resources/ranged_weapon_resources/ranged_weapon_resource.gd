extends BaseResource
class_name RangedWeaponResource

## Weapon Attributes
@export var damage: int

## Timing Variables
@export var windup_time: float 
@export var attack_duration: float 
@export var cooldown_time: float 
@export var magazine_size: int

## Visual & UI Elements
@export var model: PackedScene

func _init() -> void:
	type = ItemEnums.ItemTypes.RANGED_WEAPON
