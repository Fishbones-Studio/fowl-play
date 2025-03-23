## Script for moving along a Path3D
## Requires a Path3D node as a parent, with a curve defined. All children of the PathFollow3D will be moved along the path

extends PathFollow3D

enum MovementMode { ONCE, LOOP, PING_PONG } ## Movement modes for the path, LOOP: loops the path, PING_PONG: moves back and forth, ONCE: moves once and stops
@export var movement_speed: float = 3.0 ## Speed of movement along the path
@export var movement_mode: MovementMode = MovementMode.LOOP ## Movement mode of the path

var _current_direction: float = 1.0


func _process(delta: float) -> void:
	var path3d: Path3D = get_parent() as Path3D
	if path3d and path3d.curve:
		# getting the baked length of the path, which is an aproximation of the length of the path (good enough for this)
		_update_path_progress(delta, path3d.curve.get_baked_length())


func _update_path_progress(delta: float, path_length: float) -> void:
	var base_progress: float = progress
	var new_progress: float = base_progress + delta * movement_speed * _current_direction

	if new_progress > path_length:
		handle_path_end(path_length, new_progress - path_length)
	elif new_progress < 0:
		handle_path_start(-new_progress)
	else:
		progress = new_progress


func handle_path_end(path_length: float, overflow: float) -> void:
	match movement_mode:
		MovementMode.LOOP:
			progress = overflow
		MovementMode.PING_PONG:
			_current_direction *= -1
			progress = path_length - overflow
		_:
			progress = path_length


func handle_path_start(underflow: float) -> void:
	match movement_mode:
		MovementMode.LOOP:
			progress = get_parent().curve.get_baked_length() - underflow
		MovementMode.PING_PONG:
			_current_direction *= -1
			progress = underflow
		_:
			progress = 0
