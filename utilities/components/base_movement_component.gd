################################################################################
## Base movement component that handles core physics calculations for entity movement.
## Serves as a base class for specialized movement components.
################################################################################
class_name BaseMovementComponent
extends Node

# Physics constants
const DEFAULT_JUMP_HEIGHT: float = 5.0  # meters
const DEFAULT_TIME_TO_PEAK: float = 0.4  # seconds for default height
const DEFAULT_TIME_TO_DESCENT: float = 0.3  # seconds for default height

@export var entity: PhysicsBody3D

@export_category("Jump Settings")
@export var jump_height: float = DEFAULT_JUMP_HEIGHT:
	set(value):
		jump_height = max(value, 0.1)
		_recalculate_jump_params()

# Physics state
var jump_velocity: float = 0.0
var jump_gravity: float = 0.0
var fall_gravity: float = 0.0

var time_to_peak: float = 0.0
var time_to_descent: float = 0.0


func _ready():
	_recalculate_jump_params()


## Solves for initial velocity and gravity to achieve specified jump arc
## Uses kinematic equations derived from real physics principles:
## - Displacement = initial_velocity * time + 0.5 * acceleration * time²
## - Rearrange to solve for velocity = 2 * displacement / time
## - Rearrange to solve for accelleration = 2 * displacement / time²
func _recalculate_jump_params():
	time_to_peak = DEFAULT_TIME_TO_PEAK * sqrt(jump_height / DEFAULT_JUMP_HEIGHT)
	time_to_descent = DEFAULT_TIME_TO_DESCENT * sqrt(jump_height / DEFAULT_JUMP_HEIGHT)
	
	# Calculate physics values
	jump_velocity = (2.0 * jump_height) / time_to_peak
	jump_gravity = (-2.0 * jump_height) / (time_to_peak * time_to_peak)
	fall_gravity = (-2.0 * jump_height) / (time_to_descent * time_to_descent)


## Uses square root scaling for realistic weight distribution
func _update_physics_based_on_weight(weight: float) -> void:
	jump_height /= sqrt(weight)
	_recalculate_jump_params()


func get_jump_velocity() -> float:
	return jump_velocity


## Returns the appropriate gravity value based on movement state
func get_gravity(velocity: Vector3) -> float:
	return jump_gravity if velocity.y > 0 else fall_gravity
