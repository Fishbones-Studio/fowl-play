# WeaponResource: Defines weapon properties that can be used across different weapons.
class_name MeleeWeaponResource
extends BaseResource

# Weapon Attributes
@export var damage: int = 0
# Timing Variables
@export var windup_time: float = 0.0
@export var attack_duration: float = 0.0
@export var cooldown_time: float = 0.0


func _init() -> void:
	type = ItemEnums.ItemTypes.MELEE_WEAPON


func get_modifier_string(hex_code: String = "#ffff00") -> Array[String]:
	var modifiers: Array[String] = []

	modifiers.append("[color=%s]%d[/color]" % [hex_code, damage])

	modifiers.append("[color=%s]%.2fs[/color]" % [hex_code, windup_time])

	modifiers.append("[color=%s]%.2fs[/color]" % [hex_code, attack_duration])

	modifiers.append("[color=%s]%.2fs[/color]" % [hex_code, cooldown_time])

	return modifiers


func get_modifier() -> Array[float]:
	var modifiers: Array[float] = []

	modifiers.append(damage)
	modifiers.append(windup_time)

	modifiers.append(attack_duration)

	modifiers.append(cooldown_time)

	return modifiers
