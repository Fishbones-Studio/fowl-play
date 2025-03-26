## This hazard applies damage at tick based intervals
## The damage applies while the entity is in the hazard area, and immediately stops on exit
class_name HoldHazard
extends BaseHazard

@export var damage_interval: float = 2.0  ## Time between damage ticks


func _process(_delta: float) -> void:
	if active_bodies.size() > 0:
		_apply_continuous_damage()
	super(_delta)


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body is PhysicsBody3D:
		var id: int = body.get_instance_id()
		if not active_bodies.has(id):
			active_bodies[id] = Time.get_ticks_msec()


func _on_hazard_area_body_exited(body: Node3D) -> void:
	if body is PhysicsBody3D:
		var id: int = body.get_instance_id()
		active_bodies.erase(id)


func _apply_continuous_damage() -> void:
	var current_time: int = Time.get_ticks_msec()

	for id in active_bodies:
		var body: PhysicsBody3D = instance_from_id(id)

		if not is_instance_valid(body):
			bodies_to_remove.append(id)
			continue

		var elapsed: float = (current_time - active_bodies[id]) / 1000.0
		if fmod(elapsed, damage_interval) < 0.01: # Small threshold for float comparison
			print("Temp hold hazard hurt entity")
			super._on_hazard_area_body_entered(body)
