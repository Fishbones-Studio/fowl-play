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


func get_modifier_string(hex_code: String = "#ffff00") -> Array[String]:
	var modifiers: Array[String] = []

	if damage:
		modifiers.append("[color=%s]%d[/color]" % [hex_code, damage])
	if windup_time:
		modifiers.append("[color=%s]%.2fs[/color]" % [hex_code, windup_time])
	if attack_duration:
		modifiers.append("[color=%s]%.2fs[/color]" % [hex_code, attack_duration])
	if cooldown_time:
		modifiers.append("[color=%s]%.2fs[/color]" % [hex_code, cooldown_time])

	return modifiers
