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
@export var fire_rate_per_second : float = 0.0 # for interval based weapons
@export var max_range : float = 100.0 # for ranged weapons


func _init() -> void:
	type = ItemEnums.ItemTypes.RANGED_WEAPON
