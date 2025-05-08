class_name UpgradeResource
extends BaseResource

@export_group("Upgrade Settings")
@export var health_bonus: int = 0
@export var stamina_bonus: int = 0
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var speed_bonus: int = 0
@export var weight_bonus: float = 0.0


func _init() -> void:
	type = ItemEnums.ItemTypes.UPGRADE


func get_modifier_string(hex_code: String = "#ffff00") -> Array[String]:
	var modifiers: Array[String] = []

	if health_bonus != 0:
		modifiers.append("[color=%s]%+d[/color]" % [hex_code, health_bonus])
	if stamina_bonus != 0:
		modifiers.append("[color=%s]%+d[/color]" % [hex_code, stamina_bonus])
	if attack_bonus != 0:
		modifiers.append("[color=%s]%+d[/color]" % [hex_code, attack_bonus])
	if defense_bonus != 0:
		modifiers.append("[color=%s]%+d[/color]" % [hex_code, defense_bonus])
	if speed_bonus != 0:
		modifiers.append("[color=%s]%+d[/color]" % [hex_code, speed_bonus])
	if weight_bonus != 0.0:
		modifiers.append("[color=%s]%+.2f[/color]" % [hex_code, weight_bonus])

	return modifiers
