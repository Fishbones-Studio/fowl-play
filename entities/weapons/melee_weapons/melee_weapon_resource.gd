# WeaponResource: Defines weapon properties that can be used across different weapons.
class_name MeleeWeaponResource
extends BaseResource

# Weapon Attributes
@export_group("Melee Weapon Attributes")
@export var damage: int
# Timing Variables
@export var windup_time: float
@export var attack_duration: float
@export var cooldown_time: float
@export var stun_time: float
# Animation Variables
@export_group("Animation")
@export var loop_animation := false


func _init() -> void:
	type = ItemEnums.ItemTypes.MELEE_WEAPON


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


func get_modifier() -> Array[float]:
	var modifiers: Array[float] = []

	if damage:
		modifiers.append(damage)
	else:
		modifiers.append(0.0)

	if windup_time:
		modifiers.append(windup_time)
	else:
		modifiers.append(0.0)

	if attack_duration:
		modifiers.append(attack_duration)
	else:
		modifiers.append(0.0)

	if cooldown_time:
		modifiers.append(cooldown_time)
	else:
		modifiers.append(0.0)

	return modifiers
