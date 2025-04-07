class_name KnockHazard
extends BaseHazard

@export var knockback_force: float = 5.0
@export var vertical_knockback: float = 5.0

@onready var hazard_area: Area3D = $HazardArea


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		# Calculate knockback direction
		var knockback_direction: Vector3 = self.global_position.direction_to(body.global_position)

		var knockback: Vector3 = Vector3(
			knockback_direction.x * knockback_force,
			abs(knockback_direction.y) + vertical_knockback,
			knockback_direction.z * knockback_force,
		)

		if body.collision_layer == 2:
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.HURT_STATE, {
				"knockback": knockback,
				})
		else:
			body.velocity += knockback

		# Apply damage
		super(body)
