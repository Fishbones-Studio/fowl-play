extends BaseResource
class_name PassiveResource

## stat effects
@export var HPShift: int
@export var DefenseShift: int
@export var WeightShift: int
@export var SpeedShift: int

func _init() -> void:
	type = ItemEnums.ItemTypes.PASSIVE
