class_name BasePlayerMovementState
extends BaseState

@export var state_type: PlayerEnums.PlayerStates

var player: ChickenPlayer
var previous_state: BasePlayerMovementState
var movement_component: PlayerMovementComponent
var animation_tree: AnimationTree


## Called once when entering the state.
##
## Parameters:
## prev_state: The state that was active before this one.
func enter(prev_state: BasePlayerMovementState, _info: Dictionary = {}) -> void:
	previous_state = prev_state


################################################################################
# The following are non spefic FSM-methods, i.e. utility methods
# that may be used by multiple states.
################################################################################


## Applies jump or fall gravity based on player velocity
func apply_gravity(delta: float) -> void:
	player.velocity.y += movement_component.get_gravity(player.velocity) * delta


func apply_movement(velocity: Vector3) -> void:
	player.velocity.x = velocity.x
	player.velocity.z = velocity.z
	player.move_and_slide()


func is_sprinting() -> bool:
	return Input.is_action_pressed("sprint") and player.stats.current_stamina >= movement_component.sprint_stamina_threshold


func get_gravity(velocity: Vector3) -> float:
	return movement_component.get_gravity(velocity)


func get_jump_velocity() -> float:
	return movement_component.get_jump_velocity()


func get_player_input_dir() -> Vector2:
	return movement_component.get_player_input_dir()


func get_player_direction() -> Vector3:
	return movement_component.get_player_direction()
