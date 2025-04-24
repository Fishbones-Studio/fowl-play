class_name AbilityResource
extends BaseResource

@export var cooldown: float


func _init() -> void:
	type = ItemEnums.ItemTypes.ABILITY
	type_max_owned_amount = 2


func get_modifier_string() -> Array[String]:
	var modifiers: Array[String] = []

	if cooldown:
		modifiers.append("%.2fs" % cooldown)

	return modifiers
