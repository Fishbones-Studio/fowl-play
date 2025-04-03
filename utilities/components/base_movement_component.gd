################################################################################
## Base movement component that handles core physics calculations for 
## entity movement.
## It servers as a blase class for specialized movement components.
################################################################################
class_name BaseMovementComponent
extends Node

# Ratio defaults (adjust these to tweak feel)
const DEFAULT_PEAK_RATIO: float = 30 # seconds per meter of jump height
const DEFAULT_FALL_RATIO: float = 36 # seconds per meter of jump height

@export var entity: Node3D

@export_category("Jump")
@export var jump_height: float = 5.0:
	set(value):
		jump_height = value
		_recalculate_jump_params()

# Default time values (will be auto-calculated if not set)
var time_to_peak: float = 0.0  # 0 means auto-calculate
var time_to_ground: float = 0.0 # 0 means auto-calculate

var jump_velocity: float
var jump_gravity: float
var fall_gravity: float


func _ready():
	_recalculate_jump_params()


func _recalculate_jump_params():
	# Calculate times if not manually specified
	if time_to_peak <= 0:
		time_to_peak = jump_height / DEFAULT_PEAK_RATIO
	if time_to_ground <= 0:
		time_to_ground = jump_height / DEFAULT_FALL_RATIO

	# Calculate physics values
	jump_velocity = (1.5 * jump_height) / time_to_peak
	jump_gravity = (-jump_height) / (time_to_peak * time_to_peak)
	fall_gravity = (-jump_height) / (time_to_ground * time_to_ground)


## Update the vertical motion physics based on weight
func update_physics_by_weight(weight: int):
	# Calculate weight multiplier using logarithmic scaling,
	# we use 3 (kg) as standard weight. So 3 (kg) would give a multiplier of 1.0
	# NOTE: tweek/experiment with formula and weight factor.\
	# NOTE: Do not set weight to 1 or below
	var weight_multiplier: float = 1.0 + (log(weight / 3.0) / log(3.0))

	# Adjust physics parameters based on weight
	jump_height = jump_height / weight_multiplier


func get_jump_velocity() -> float:
	return jump_velocity


## Return custom calculated gravity
func get_gravity(velocity: Vector3) -> float:
	return jump_gravity if velocity.y > 0 else fall_gravity
