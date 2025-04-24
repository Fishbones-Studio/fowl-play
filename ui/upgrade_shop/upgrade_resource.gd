class_name UpgradeResource
extends BaseResource

@export var health_bonus: float = 0.0
@export var stamina_bonus: float = 0.0
@export var attack_multiplier_bonus: float = 0.0
@export var defense_bonus: int = 0
@export var speed_bonus: float = 0.0
@export var weight_bonus: float = 0.0


func _init() -> void:
	type = ItemEnums.ItemTypes.UPGRADE


# TODO, add back the bbcCode
func get_modifier_string() -> Array[String]:
	var modifiers: Array[String] = []

	if health_bonus != 0.0:
		modifiers.append("%+.2f" % health_bonus)
	if stamina_bonus != 0.0:
		modifiers.append("%+.2f" % stamina_bonus)
	if attack_multiplier_bonus != 0.0:
		modifiers.append("%+.2f" % attack_multiplier_bonus)
	if defense_bonus != 0:
		modifiers.append("%+d" % defense_bonus)
	if speed_bonus != 0.0:
		modifiers.append("%+.2f" % speed_bonus)
	if weight_bonus != 0.0:
		modifiers.append("%+.2f" % weight_bonus)

	return modifiers
