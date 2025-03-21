extends BaseHazard

@export var damage_interval: float = 1.0  ## Time between damage ticks
@export var damage_duration: float = 5.0  ## Total duration of damage

var _active_bodies: Dictionary[PhysicsBody3D, int] = {}


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body is PhysicsBody3D and not _active_bodies.has(body):
		_active_bodies[body as PhysicsBody3D] = Time.get_ticks_msec()
		print(_active_bodies)


func _process(_delta: float) -> void:
	if _active_bodies.size() > 0:
		_apply_continuous_damage()


func _apply_continuous_damage() -> void:
	var current_time: int = Time.get_ticks_msec()

	for body in _active_bodies:
		if not is_instance_valid(body):
			_active_bodies.erase(body)
			continue

		var elapsed: float = (current_time - _active_bodies[body]) / 1000.0
		if elapsed >= damage_duration:
			_active_bodies.erase(body)
		elif fmod(elapsed, damage_interval) < 0.01: # Small threshold for float comparison
			print("Sting hazard hurt entity")
			super._on_hazard_area_body_entered(body)
	
