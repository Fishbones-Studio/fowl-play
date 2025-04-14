class_name AbilityResource
extends BaseResource

@export var damage: int
@export var cooldown: float


func _init() -> void:
	type = ItemEnums.ItemTypes.ABILITY
	type_max_owned_amount = 2
