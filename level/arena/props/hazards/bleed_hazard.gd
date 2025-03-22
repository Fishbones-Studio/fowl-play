## This hazard applies damage at tick based intervals
## The damage applies after the entity touches the hazard area, and then damages the player for a set duration
class_name BleedHazard
extends  BaseHazard

@export var damage_interval: float = 1.0  ## Time between damage ticks
@export var damage_duration: float = 5.0  ## Total duration of damage


func _process(_delta: float) -> void:
	if active_bodies.size() > 0:
		_apply_continuous_damage()


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body is PhysicsBody3D and not active_bodies.has(body):
		active_bodies[body as PhysicsBody3D] = Time.get_ticks_msec()


func _apply_continuous_damage() -> void:
	var current_time: int = Time.get_ticks_msec()

	for body in active_bodies:
		if not is_instance_valid(body):
			active_bodies.erase(body)
			continue

		var elapsed: float = (current_time - active_bodies[body]) / 1000.0
		if elapsed >= damage_duration:
			active_bodies.erase(body)
		elif fmod(elapsed, damage_interval) < 0.01: # Small threshold for float comparison
			print("Sting hazard hurt entity")
			super._on_hazard_area_body_entered(body)
	
