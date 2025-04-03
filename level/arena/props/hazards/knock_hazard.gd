class_name KnockHazard
extends BaseHazard

@export var knockback_strength: float = 220.0
@export var vertical_knockback: float = 20.0
@export var hazard_object: Node3D

var _knockback_force: Vector3


func _process(_delta: float) -> void:
	super(_delta)


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		var knockback_direction: Vector3 = hazard_object.global_position.direction_to(body.global_position)

		_knockback_force = Vector3(
			knockback_direction.x + knockback_strength,
			vertical_knockback,
			knockback_direction.z + knockback_strength
		)
		
		body.velocity = _knockback_force
		body.move_and_slide()
		super._on_hazard_area_body_entered(body)
