################################################################################
## Base movement component that handles core physics calculations for 
## entity movement.
## It servers as a blase class for move specialized movement components.
################################################################################
class_name BaseMovementComponent
extends Node

@export var entity: Node3D

@export_category("Jump")
@export var jump_height: float = 5.0
@export var time_to_peak: float = 0.6
@export var time_to_ground: float = 0.5

var jump_velocity: float
var jump_gravity: float
var fall_gravity: float


## Update the vertical motion physics based on weight
func update_physics_by_weight(weight: int):
	# Calculate weight multiplier using logarithmic scaling,
	# we use 3 (kg) as standard weight. So 3 (kg) would give a multiplier of 1.0
	# NOTE: tweek/experiment with formula and weight factor.
	var weight_multiplier: float = 1.0 + (log(weight / 3.0) / log(3.0))
	
	# Adjust physics parameters based on weight
	jump_height = jump_height / weight_multiplier
	time_to_peak = time_to_peak / weight_multiplier
	time_to_ground = time_to_ground / weight_multiplier
	
	# Recalculate velocity and gravity
	jump_velocity = (2.0 * jump_height) / time_to_peak
	jump_gravity = (-2.0 * jump_height) / (time_to_peak * time_to_peak)
	fall_gravity = (-2.0 * jump_height) / (time_to_ground * time_to_ground)


func get_jump_velocity() -> float:
	return jump_velocity


## Return custom calculated gravity
func get_gravity(velocity: Vector3) -> float:
	return jump_gravity if velocity.y > 0 else fall_gravity
