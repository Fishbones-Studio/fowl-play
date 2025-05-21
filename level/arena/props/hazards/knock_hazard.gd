class_name KnockHazard
extends BaseHazard

@export var knockback_force: float = 5.0
@export var minimum_horizontal_knockback: float = 1.1
@export var minimum_vertical_knockback: float = 7.0
@export var maximum_horizontal_knockback: float = 3.0
@export var maximum_vertical_knockback: float = 10.0

@onready var hazard_area: Area3D = $HazardArea


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if not body is CharacterBody3D:
		return

	# Calculate knockback direction
	var knockback_direction: Vector3 = self.global_position.direction_to(body.global_position)

	hazard_information = {
		"knockback": calculate_knockback(knockback_direction)
	}

	super._on_hazard_area_body_entered(body)


func calculate_knockback(direction: Vector3) -> Vector3:
	var horizontal_component := func(axis: float) -> float:
		var magnitude: float = abs(axis) * knockback_force
		magnitude = clamp(magnitude, minimum_horizontal_knockback, maximum_horizontal_knockback)
		return magnitude * sign(axis)

	var knockback: Vector3 = Vector3(
		horizontal_component.call(direction.x),
		clamp(max(abs(direction.y) * knockback_force, minimum_vertical_knockback), minimum_vertical_knockback, maximum_vertical_knockback),
		horizontal_component.call(direction.z)
	)

	return knockback
