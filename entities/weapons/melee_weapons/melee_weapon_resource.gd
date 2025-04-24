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
