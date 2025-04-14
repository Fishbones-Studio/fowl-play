class_name BaseEnemyMovementState
extends BaseState

@export var enemy: Enemy
var movement_component : EnemyMovementComponent
var steering_force : Vector3

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


func get_gravity(velocity: Vector3) -> float:
	return movement_component.get_gravity(velocity)


func get_jump_velocity() -> float:
	return movement_component.get_jump_velocity()
