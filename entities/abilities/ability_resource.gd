class_name AbilityResource
extends BaseResource

@export var cooldown: float


func _init() -> void:
	type = ItemEnums.ItemTypes.ABILITY
	type_max_owned_amount = 2


func get_modifier_string(hex_code: String = "#ffff00") -> Array[String]:
	var modifiers: Array[String] = []

	modifiers.append("[color=%s]%.2fs[/color]" % [hex_code, cooldown])

	return modifiers


func get_modifier() -> Array[float]:
	var modifiers: Array[float] = []

	modifiers.append(cooldown)

	return modifiers
