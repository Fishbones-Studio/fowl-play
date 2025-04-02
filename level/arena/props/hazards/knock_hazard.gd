class_name KnockHazard
extends BaseHazard

@export var knockback_strength: float = 20.0
@export var vertical_knockback: float = 12.0

var _knockback_force: Vector3


func _process(_delta: float) -> void:
	super(_delta)


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		var knockback_direction: Vector3 = body.transform.basis.z

		_knockback_force = Vector3(
			knockback_direction.x + knockback_strength,
			vertical_knockback,
			knockback_direction.z + knockback_strength
		)

		# Apply initial knockback force
		body.velocity = _knockback_force
		super._on_hazard_area_body_entered(body)
