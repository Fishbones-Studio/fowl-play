class_name EnemyMovementComponent
extends BaseMovementComponent

@export_category("Speed Factors")
@export var walk_speed_factor: float = 1.0
@export var sprint_speed_factor: float = 1.5
@export var dash_speed_factor: float = 8.0

@export_range(0, 1, 0.01) var glide_speed_factor: float = 0.1
@export_category("Stamina Cost")
@export var sprint_stamina_cost: int = 20
@export var dash_stamina_cost: int = 30
@export var glide_stamina_cost: int = 20

var dash_available: bool = true
var jump_available: bool = true


func _ready() -> void:
	update_physics_by_weight(entity.stats.weight)

#TODO implement enemy jump
#func get_jump_velocity() -> float:
#	return jump_velocity if Input.is_action_just_pressed("jump") else 0.0
