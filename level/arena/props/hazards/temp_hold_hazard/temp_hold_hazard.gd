## This serves as a temporary hazard that applies damage at tick based intervals
## The damage applies while the entity is in the hazard area, and immediately stops on exit

extends BaseHazard

@export var damage_interval: float = 2.0  ## Time between damage ticks


func _process(_delta: float) -> void:
	if active_bodies.size() > 0:
		_apply_continuous_damage()


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body is PhysicsBody3D and not active_bodies.has(body):
		active_bodies[body as PhysicsBody3D] = Time.get_ticks_msec()


func _on_hazard_area_body_exited(_body: Node3D) -> void:
	active_bodies.erase(_body)


func _apply_continuous_damage() -> void:
	var current_time: int = Time.get_ticks_msec()

	for body in active_bodies:
		if not is_instance_valid(body):
			active_bodies.erase(body)
			continue

		var elapsed: float = (current_time - active_bodies[body]) / 1000.0
		if fmod(elapsed, damage_interval) < 0.01: # Small threshold for float comparison
			print("Temp hold hazard hurt entity")
			super._on_hazard_area_body_entered(body)
