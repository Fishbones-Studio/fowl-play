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
@export var fire_rate_per_second: float = 0.0 # for interval based weapons
@export var max_range: float = 100.0 # for ranged weapons


func _init() -> void:
	type = ItemEnums.ItemTypes.RANGED_WEAPON


# todo, display others
func get_modifier_string() -> Array[String]:
	var modifiers: Array[String] = []

	if damage:
		modifiers.append("%d" % damage)
	if windup_time:
		modifiers.append("%.2fs" % windup_time)
	if attack_duration:
		modifiers.append("%.2fs" % attack_duration)
	if cooldown_time:
		modifiers.append("%.2fs" % cooldown_time)

	return modifiers
