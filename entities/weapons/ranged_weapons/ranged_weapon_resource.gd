class_name RangedWeaponResource
extends BaseResource

# Weapon Attributes
@export var damage: int
# Timing Variables
@export var windup_time: float
@export var attack_duration: float
@export var cooldown_time: float


func _init() -> void:
	type = ItemEnums.ItemTypes.RANGED_WEAPON
