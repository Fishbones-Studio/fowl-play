extends BaseRangedCombatState

@export var attack_origin: Node3D

var _pending_raycast: RayCast3D = null

@onready var feather_model : Node3D = $"../../feather"
@onready var wind_effect : GPUParticles3D = $"../../feather/WindEffect"

func enter(_previous_state, _info: Dictionary = {}) -> void:
	if weapon.entity_stats.is_player:
		SignalManager.cooldown_item_slot.emit(
			weapon.current_weapon,
			weapon.current_weapon.attack_duration,
			false
		)
	_pending_raycast = null
	_fire_single_shot()
	wind_effect.emitting = true
	feather_model.visible = true

func physics_process(_delta: float) -> void:
	if is_instance_valid(_pending_raycast):
		feather_model.global_position = _pending_raycast.global_position
		if _pending_raycast.is_colliding():
			process_raycast_hit(_pending_raycast, DamageEnums.DamageTypes.TRUE)
			_pending_raycast = null
			
			transition_signal.emit(WeaponEnums.WeaponState.COOLDOWN, {})

func exit() -> void:
	_pending_raycast = null
	# Resetting the feather model position to zero
	wind_effect.emitting = false
	feather_model.visible = false
	feather_model.position = Vector3.ZERO

func _fire_single_shot() -> void:
	var fire_direction: Vector3 = -attack_origin.global_basis.z.normalized()
	var max_range: float = weapon.current_weapon.max_range

	_pending_raycast = _create_raycast(attack_origin.global_position, fire_direction, max_range)

func _create_raycast(
	origin: Vector3,
	direction: Vector3,
	max_range: float
) -> RayCast3D:
	var raycast := RayCast3D.new()
	raycast.enabled = true
	raycast.target_position = direction * max_range
	raycast.collision_mask = 0b0111

	get_tree().root.add_child(raycast)
	raycast.global_position = origin

	var timer := Timer.new()
	raycast.add_child(timer)
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.timeout.connect(
		func():
			if is_instance_valid(raycast) and raycast.is_inside_tree():
				raycast.queue_free()
	)
	timer.start()

	return raycast
