extends BaseRangedCombatState

@export var attack_origin: Node3D
@export var max_range: float = 100.0
@export var spiral_spread: float = 5.0
@export var max_spread_angle: float = 15.0  # Maximum bullet spread from center

var _fire_timer: float = 0.0
var _fire_duration: float = 0.0
var _current_angle: float = 0.0
var _angle_direction: int = 1

func enter(_previous_state, _info: Dictionary = {}) -> void:
	_fire_timer = 0.0
	_fire_duration = 0.0
	_current_angle = 0.0
	_angle_direction = 1

func physics_process(delta: float) -> void:
	_fire_timer += delta
	_fire_duration += delta

	# Calculate fire rate based on weapon resource
	var fire_rate: float = weapon.current_weapon.fire_rate_per_second

	while _fire_timer >= fire_rate:
		_fire_timer -= fire_rate
		_fire_bullet()

	if _fire_duration >= weapon.current_weapon.attack_duration:
		transition_signal.emit(WeaponEnums.WeaponState.COOLDOWN, {})

func _fire_bullet() -> void:
	var fire_direction: Vector3 = _calculate_spiral_direction()

	# Get world space positions
	var origin: Vector3 = attack_origin.position
	var end: Vector3 = origin + fire_direction * max_range

	# Debug draw (lasts 3 frames)
	DebugDrawer.draw_debug_trajectory(origin, end, weapon)

	var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end)
	params.collide_with_areas = true
	params.collide_with_bodies = true

	var result: Dictionary = weapon.get_world_3d().direct_space_state.intersect_ray(params)
	if result:
		process_hit(result)
		DebugDrawer.draw_debug_impact(result.position, weapon)

	# Update spiral pattern with angle clamping
	_current_angle += spiral_spread * _angle_direction
	_current_angle = wrapf(_current_angle, -max_spread_angle, max_spread_angle)
	_angle_direction *= -1

func _calculate_spiral_direction() -> Vector3:
	var base_forward: Vector3 = attack_origin.basis.z
	var rotation_axis: Vector3 = attack_origin.basis.y
	var angle_rad: float = deg_to_rad(_current_angle)
	return base_forward.rotated(rotation_axis, angle_rad).normalized()
