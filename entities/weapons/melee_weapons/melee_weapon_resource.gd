# WeaponResource: Defines weapon properties that can be used across different weapons.
class_name MeleeWeaponResource
extends BaseResource

# Weapon Attributes
@export var damage: int
# Timing Variables
@export var windup_time: float
@export var attack_duration: float
@export var cooldown_time: float


func _init() -> void:
	type = ItemEnums.ItemTypes.MELEE_WEAPON
