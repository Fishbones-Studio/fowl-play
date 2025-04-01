class_name PlayerMovementComponent
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


func get_jump_velocity() -> float:
	return jump_velocity if Input.is_action_just_pressed("jump") else 0.0


## Get player 2D movement input vector
func get_player_input_dir() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")


## Get player movement direction
func get_player_direction() -> Vector3:
	var input_dir: Vector2 = get_player_input_dir()
	return entity.transform.basis * (Vector3(input_dir.x, 0, input_dir.y)).normalized()
