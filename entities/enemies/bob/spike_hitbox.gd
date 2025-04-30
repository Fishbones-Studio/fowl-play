extends Area3D

var damage: float:
	get: return max(owner.velocity.length() * 0.5, 1.0)

var knockback_force: float:
	get: return owner.velocity.length() * 0.1

var _hit_bodies: Array = []

@onready var hurt_timer: Timer = $HurtTimer


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body in _hit_bodies:
			return

		if body.collision_layer == 2:
			SignalManager.weapon_hit_target.emit(body, damage, DamageEnums.DamageTypes.NORMAL)
			_apply_knockback(body)
			_hit_bodies.append(body)
			hurt_timer.start()


func _on_hurt_timer_timeout() -> void:
	_hit_bodies.clear()


func _apply_knockback(body: Node3D) -> void:
	if body is ChickenPlayer:
		var dir = owner.global_position.direction_to(body.global_position)
		var knockback = dir * knockback_force
		var immobile_time = max(0.02 * owner.velocity.length(), 0.1)
		print(self.name, " - damage: ", damage)
		print(self.name, " - knockback force: ", knockback_force)
		print(self.name, " - immobile time: ", immobile_time)

		SignalManager.player_transition_state.emit(
			PlayerEnums.PlayerStates.HURT_STATE,
			{
				"knockback": knockback,
				"immobile_time": immobile_time
			}
		)
