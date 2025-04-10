class_name BaseEnemyMovementState
extends BaseState

@export var enemy: Enemy
var movement_component : EnemyMovementComponent
################################################################################
# The following are non spefic FSM-methods, i.e. utility methods
# that may be used by multiple states.
################################################################################


## Applies jump or fall gravity based on player velocity
func apply_gravity(delta: float) -> void:
	enemy.velocity.y += movement_component.get_gravity(enemy.velocity) * delta


func apply_movement(velocity: Vector3) -> void:
	enemy.velocity.x = velocity.x
	enemy.velocity.z = velocity.z
	enemy.move_and_slide()

func get_gravity(velocity: Vector3) -> float:
	return movement_component.get_gravity(velocity)


func get_jump_velocity() -> float:
	return movement_component.get_jump_velocity()
