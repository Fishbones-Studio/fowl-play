## Hazard that follows a path with configurable movement behavior
extends BleedHazard

enum MovementMode { ONCE, LOOP, PING_PONG }

@export var movement_speed: float = 6.0
@export var movement_mode: MovementMode = MovementMode.LOOP
@export var path_follow: PathFollow3D  ## PathFollow3D node to follow, leave empty to disable path following

var _current_direction: float = 1.0

func _process(delta: float) -> void:
	if path_follow:
		var path3d: Path3D = path_follow.get_parent() as Path3D
		if path3d and path3d.curve:
			_update_path_progress(delta, path3d.curve.get_baked_length())

	# Parent class handles damage logic
	super._process(delta)

func _update_path_progress(delta: float, path_length: float) -> void:
	var base_progress: float = path_follow.progress
	var new_progress: float = base_progress + delta * movement_speed * _current_direction

	if new_progress > path_length:
		handle_path_end(path_length, new_progress - path_length)
	elif new_progress < 0:
		handle_path_start(-new_progress)
	else:
		path_follow.progress = new_progress

func handle_path_end(path_length: float, overflow: float) -> void:
	match movement_mode:
		MovementMode.LOOP:
			path_follow.progress = overflow
		MovementMode.PING_PONG:
			_current_direction *= -1
			path_follow.progress = path_length - overflow
		_:
			path_follow.progress = path_length

func handle_path_start(underflow: float) -> void:
	match movement_mode:
		MovementMode.LOOP:
			path_follow.progress = path_follow.get_parent().curve.get_baked_length() - underflow
		MovementMode.PING_PONG:
			_current_direction *= -1
			path_follow.progress = underflow
		_:
			path_follow.progress = 0
