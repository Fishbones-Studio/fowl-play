class_name EggBomb
extends BaseHazard

@export var knockback_force: float = 3.0
@export var vertical_knockback_force: float = 3.0
@export var despawn_time: float = 5.0

var spawner: CharacterBody3D

var _hit_bodies: Array[CharacterBody3D] = []

@onready var hazard_area: Area3D = $HazardArea
@onready var despawn_timer: Timer = $DespawnTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var explosion_sound: RandomSFXPlayer = $ExplosionSound
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var explosion_area: Area3D = $ExplosionArea


func _ready() -> void:
	despawn_timer.wait_time = despawn_time

	despawn_timer.start()
	animation_player.play("idle")

	if not spawner:
		return

	match spawner.collision_layer:
		2: # Disable collision with player
			hazard_area.set_collision_mask_value(2, false)
			explosion_area.set_collision_mask_value(2, false)
		4: # Disable collision with enemy
			hazard_area.set_collision_mask_value(3, false)
			explosion_area.set_collision_mask_value(3, false)


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if not body is CharacterBody3D:
		return

	if _hit_bodies.has(body):
		return

	_hit_bodies.append(body)
	_explode()


func _calculate_knockback(body: Node3D) -> Vector3:
	if body is CharacterBody3D:
		var dir: Vector3 = self.global_position.direction_to(body.global_position)

		var knockback: Vector3 = Vector3(
			sign(dir.x) * knockback_force,
			(sign(dir.y) if dir.y != 0 else 1) * knockback_force,
			sign(dir.z) * knockback_force,
		)

		return knockback if is_zero_approx(body.velocity.y) else knockback / 2.5

	return Vector3.ZERO


func _on_despawn_timer_timeout() -> void:
	_explode()


func _explode() -> void:
	for body in _hit_bodies:
		hazard_information = {
			"knockback": _calculate_knockback(body),
		}

		super._on_hazard_area_body_entered(body)

		if not despawn_timer.is_stopped(): despawn_timer.stop()
	animation_player.play("explode")


func _remove_self() -> void:
	get_parent().remove_child(self)
	queue_free()
