class_name BaseEnemyMovementState
extends BaseState

@export var enemy: Enemy

var movement_component : EnemyMovementComponent
var steering_force : Vector3
var _direction_difference: float
var _target_rotation_reached: bool

################################################################################
# The following are non spefic FSM-methods, i.e. utility methods
# that may be used by multiple states.
################################################################################


## Applies jump or fall gravity based on velocity
func apply_gravity(delta: float) -> void:
	enemy.velocity.y += movement_component.get_gravity(enemy.velocity) * delta


func apply_movement(target_position: Vector3) -> void:
	steering_force = (target_position - enemy.velocity)
	enemy.velocity.x += steering_force.x
	enemy.velocity.z += steering_force.z
	enemy.move_and_slide()


func _rotate_toward_direction(direction: Vector3, delta: float, calculated_speed: float) -> void:
	var target_angle: float = atan2(-direction.x, -direction.z) # Calculate the angle to the target direction
	var current_angle: float = enemy.rotation.y # Get the current angle of the enemy

	# Lerp the angle to smoothly rotate towards the target direction
	var new_angle: float = lerp_angle(current_angle, target_angle, calculated_speed * delta)
	enemy.rotation.y = new_angle
	#calculate the difference between the angles as they are always slightly different from one another.
	_direction_difference = abs(current_angle - target_angle)
	if _direction_difference < 0.5:
		_target_rotation_reached = true


func get_gravity(velocity: Vector3) -> float:
	return movement_component.get_gravity(velocity)


func get_jump_velocity() -> float:
	return movement_component.get_jump_velocity()
