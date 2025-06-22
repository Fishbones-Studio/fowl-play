extends BaseRangedCombatState

@export var attack_origin: Node3D
@export_group("Wind Effect")
@export var wind_lag_time: float = 0.15
@export var _wind_attack_elapsed: float = 0.0

var _pending_raycast: RayCast3D = null
var _visualization_timer: Timer = null
var _feather_start_pos: Vector3
var _feather_end_pos: Vector3
var _attack_elapsed: float = 0.0

@onready var feather_model: Node3D = $"../../feather"
@onready var wind_effect: GPUParticles3D = $"../../WindEffect"
@onready var launch_effect: GPUParticles3D = $"../../LaunchEffect"

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
	_attack_elapsed = 0.0
	_wind_attack_elapsed = 0.0
	launch_effect.emitting = true


func physics_process(delta: float) -> void:
	if is_instance_valid(_pending_raycast):
		if _pending_raycast.is_colliding():
			process_raycast_hit(_pending_raycast, DamageEnums.DamageTypes.TRUE)
			_pending_raycast = null
		_start_visualization_timer()
	if feather_model.visible:
		# Update the feather model position based on the attack duration
		_attack_elapsed += delta
		var weight: float = clamp(_attack_elapsed / weapon.current_weapon.attack_duration, 0.0, 1.0)
		feather_model.global_position = _feather_start_pos.lerp(_feather_end_pos, weight)

		# Wind effect lags behind the feather
		_wind_attack_elapsed += delta
		var wind_weight: float = clamp((_wind_attack_elapsed - wind_lag_time) / weapon.current_weapon.attack_duration, 0.0, 1.0)
		wind_effect.global_position = _feather_start_pos.lerp(_feather_end_pos, wind_weight)


func exit() -> void:
	_pending_raycast = null
	if _visualization_timer:
		_visualization_timer.queue_free()
		_visualization_timer = null
	wind_effect.emitting = false
	feather_model.visible = false
	feather_model.position = Vector3.ZERO
	wind_effect.position = Vector3(0, 0, -0.6)


func _fire_single_shot() -> void:
	var fire_direction: Vector3 = -attack_origin.global_basis.z.normalized()
	var max_range: float = weapon.current_weapon.max_range
	_feather_start_pos = attack_origin.global_position
	_feather_end_pos = _feather_start_pos + fire_direction * max_range
	_pending_raycast = _create_raycast(_feather_start_pos, fire_direction, max_range)


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


func _start_visualization_timer() -> void:
	if _visualization_timer:
		_visualization_timer.queue_free()
	_visualization_timer = Timer.new()
	_visualization_timer.wait_time = weapon.current_weapon.attack_duration
	_visualization_timer.one_shot = true
	add_child(_visualization_timer)
	_visualization_timer.timeout.connect(_on_visualization_timer_timeout)
	_visualization_timer.start()


func _on_visualization_timer_timeout() -> void:
	transition_signal.emit(WeaponEnums.WeaponState.COOLDOWN, {})
	if _visualization_timer:
		_visualization_timer.queue_free()
		_visualization_timer = null
