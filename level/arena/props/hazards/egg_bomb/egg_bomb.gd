class_name EggBomb
extends BaseHazard

@export var knockback_force: float = 3.0
@export var vertical_knockback_force: float = 3.0
@export var despawn_time: float = 5.0

var spawner: CharacterBody3D

@onready var hazard_area: Area3D = $HazardArea
@onready var despawn_timer: Timer = $DespawnTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	despawn_timer.wait_time = despawn_time

	if not spawner:
		return

	match spawner.collision_layer:
		2: hazard_area.set_collision_mask_value(2, false)  # Disable collision with player 
		4: hazard_area.set_collision_mask_value(3, false)  # Disable collision with enemy

	despawn_timer.start()
	animation_player.play("idle")


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if not body is CharacterBody3D:
		return

	var knockback: Vector3 = _calculate_knockback(body)

	if body is Enemy:
		if body.type == EnemyEnums.EnemyTypes.BOSS:
			damage /= 10

	SignalManager.weapon_hit_target.emit(
			body,
			damage,
			DamageEnums.DamageTypes.TRUE,
			{
			"knockback": knockback,
		})

	despawn_timer.stop()
	_on_despawn_timer_timeout()


func _calculate_knockback(body: Node3D) -> Vector3:
	if body is CharacterBody3D:
		var dir: Vector3 = self.global_position.direction_to(body.global_position)

		return Vector3(
			sign(dir.x) * knockback_force,
			(sign(dir.y) if dir.y != 0 else 1) * knockback_force,
			sign(dir.z) * knockback_force,
		)

	return Vector3.ZERO


func _on_despawn_timer_timeout() -> void:
	get_parent().remove_child(self)
	queue_free()
