class_name KnockHazard
extends BaseHazard

@export var knockback_strength: float = 100.0
@export var vertical_knockback: float = 25.0

@onready var hazard_area: Area3D = $HazardArea

func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		# Calculate knockback direction
		var knockback_direction: Vector3 = (
										   body.global_position - hazard_area.global_position
										   ).normalized()

		var _knockback_force := Vector3(
			knockback_direction.x + knockback_strength,
			vertical_knockback,
			knockback_direction.z + knockback_strength
		)

		# Adding to the existing velocity
		body.velocity += _knockback_force

		# Apply damage
		super(body)
