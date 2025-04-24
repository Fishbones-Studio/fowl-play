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

	modifiers.append("[color=%s]%d[/color]" % [hex_code, damage])

	modifiers.append("[color=%s]%.2fs[/color]" % [hex_code, fire_rate_per_second])

	modifiers.append("[color=%s]%.2fs[/color]" % [hex_code, windup_time])

	modifiers.append("[color=%s]%.2fs[/color]" % [hex_code, attack_duration])

	modifiers.append("[color=%s]%.2fm[/color]" % [hex_code, max_range])

	modifiers.append("[color=%s]%.2fs[/color]" % [hex_code, cooldown_time])

	modifiers.append("[color=%s]%s[/color]" % [hex_code, "can fire continuously" if allow_continuous_fire else "fires one bullet at a time"])
	modifiers.append("[color=%s]%s[/color]" % [hex_code, "can be released mid-fire" if allow_early_release else "cannot be released mid-fire"])

	return modifiers


func get_modifier() -> Array[float]:
	var modifiers: Array[float] = []

	modifiers.append(damage)

	modifiers.append(fire_rate_per_second)

	modifiers.append(windup_time)

	modifiers.append(attack_duration)

	modifiers.append(max_range)

	modifiers.append(cooldown_time)

	return modifiers
