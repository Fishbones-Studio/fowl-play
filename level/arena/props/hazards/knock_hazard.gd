class_name KnockHazard
extends BaseHazard

@export_group("Knockback Settings")
@export var knockback_force: float = 5.0
@export var minimum_horizontal_knockback: float = 1.1
@export var minimum_vertical_knockback: float = 7.0
@export var maximum_horizontal_knockback: float = 3.0
@export var maximum_vertical_knockback: float = 10.0

@export_group("Animation Settings")
@export var animation_name: StringName
@export var animation_speed_scale: float = 1.0
@export var animation_reverse: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hazard_area: Area3D = $HazardArea


func _ready() -> void:
	animation_player.play(animation_name, -1.0, animation_speed_scale, animation_reverse)


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if not body is CharacterBody3D:
		return

	# Calculate knockback direction
	var knockback_direction: Vector3 = global_position.direction_to(body.global_position)

	hazard_information = {
		"knockback": calculate_knockback(knockback_direction, body)
	}

	super(body)


func calculate_knockback(direction: Vector3, body: CharacterBody3D) -> Vector3:
	var horizontal_component := func(axis: float) -> float:
		var magnitude: float = abs(axis) * knockback_force
		magnitude = clamp(magnitude, minimum_horizontal_knockback, maximum_horizontal_knockback)
		return magnitude * sign(axis)

	var knockback: Vector3 = Vector3(
		horizontal_component.call(direction.x),
		clamp(max(abs(direction.y) * knockback_force, minimum_vertical_knockback), minimum_vertical_knockback, maximum_vertical_knockback),
		horizontal_component.call(direction.z)
	)

	return knockback if is_zero_approx(body.velocity.y) else knockback / 2.5
