class_name EnemyMovementComponent
extends BaseMovementComponent

@export_category("Speed Factors")
@export var walk_speed_factor: float = 1.0
@export var sprint_speed_factor: float = 1.5
@export var dash_speed_factor: float = 8.0

@export_category("Stamina Cost")
@export var sprint_stamina_cost: int = 0


func _ready() -> void:
	_update_physics_based_on_weight(entity.stats.weight)
