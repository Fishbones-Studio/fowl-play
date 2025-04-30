@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"
@export var speed_factor: float = 0.0
## How long to perform this task (in seconds).
@export var duration: float = 0.1
## If the enemy should bounce on walls.
@export var bounce: bool = false
## Angle variation when bouncing (in degrees).
@export_range(0.0, 180.0) var bounce_angle_variation: float = 45.0
## Camera shake for bounce
@export_range(0.0, 30.0) var bounce_camera_shake: float = 5.0

var _current_direction: Vector3
var _timed_out: bool


# Display a customized name (requires @tool).
func _generate_name() -> String:
	var name: String = "Charge ➜ "

	if speed_factor > 0.0:
		name += "speed_factor: %.1f  " % speed_factor

	if duration != 0.1:
		name += "duration: %.1f  " % duration

	if bounce:
		name += "bounce: %s  " % bounce

	if bounce_angle_variation != 45.0:
		name += "bounce_angle_variation: %.1f  " % bounce_angle_variation

	if bounce_camera_shake != 5.0:
		name += "bounce_camera_shake: %.1f" % bounce_camera_shake

	return name if name != "Charge ➜ " else "Charge"


func _enter() -> void:
	_timed_out = false
	_current_direction = -agent.global_transform.basis.z.normalized()


# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	if _timed_out and agent.is_on_floor():
		return SUCCESS

	if elapsed_time > duration:
		_timed_out = true

	if agent.is_on_wall():
		if bounce:
			_bounce()
			return RUNNING
		else:
			return SUCCESS

	if not _timed_out:
		agent.velocity = _current_direction * _get_current_speed()

	return RUNNING


func _get_current_speed() -> float:
	var base_speed: float = agent.stats.speed

	if speed_factor > 0.0:
		return speed_factor * base_speed
	else:
		return agent.movement_component.sprint_speed_factor * base_speed


func _bounce() -> void:
	# Get normal of the wall we hit
	var wall_normal: Vector3 = agent.get_wall_normal()

	# Calculate reflection direction
	var new_direction: Vector3 = _current_direction.bounce(wall_normal)
	new_direction.y = 0 # Keep movement horizontal

	# Add some randomness to the bounce
	var random_angle: float = deg_to_rad(randf_range(-bounce_angle_variation, bounce_angle_variation))
	var rotation: Basis = Basis(Vector3.UP, random_angle) # Rotate around Y axis only

	_current_direction = (rotation * new_direction).normalized()

	_bounce_camera_shake()


func _bounce_camera_shake() -> void:
	var camera: FollowCamera = agent.get_tree().get_first_node_in_group("FollowCamera")
	camera.apply_shake(bounce_camera_shake)
