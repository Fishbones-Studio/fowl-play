class_name KnockHazard
extends BaseHazard


@export var knockback_force: float = 5.0
@export var minimum_horizontal_knockback: float = 3.0
@export var minimum_vertical_knockback: float = 5.0

@onready var hazard_area: Area3D = $HazardArea


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		# Calculate knockback direction
		var knockback_direction: Vector3 = self.global_position.direction_to(body.global_position)

		var knockback_x: float = knockback_direction.x * knockback_force
		var knockback_y: float = abs(knockback_direction.y) * knockback_force
		var knockback_z: float = knockback_direction.z * knockback_force

		var knockback: Vector3 = Vector3(
			knockback_x if abs(knockback_x) > minimum_horizontal_knockback else minimum_horizontal_knockback * sign(knockback_direction.x),
			knockback_y if knockback_y > minimum_vertical_knockback else minimum_vertical_knockback,
			knockback_z if abs(knockback_z) > minimum_horizontal_knockback else minimum_horizontal_knockback * sign(knockback_direction.z),
		)

		if body.collision_layer == 2: # Player
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.HURT_STATE, {
				"knockback": knockback,
				})
		else: # TODO: for other entities
			body.velocity += knockback

		# Apply damage
		super(body)
