class_name RangedWeaponResource
extends BaseResource

# Weapon Attributes
@export var damage: int
# Timing Variables
@export var windup_time: float
@export var attack_duration: float
@export var cooldown_time: float
@export var allow_continuous_fire: bool = false  # For hold-to-continue weapons
@export var allow_early_release: bool = false   # For interruptible attacks


func _init() -> void:
	type = ItemEnums.ItemTypes.RANGED_WEAPON
