extends BaseRangedCombatState

@export var attack_origin: Vector3
@export var max_range: float = 1000.0
@export var spiral_spread: float = 5.0

var _fire_timer: float = 0.0
var _current_angle: float = 0.0
var _angle_direction: int = 1

func enter(_previous_state, _info: Dictionary = {}) -> void:
	_fire_timer = 0.0
	_current_angle = 0.0
	_angle_direction = 1

func physics_process(delta: float) -> void:
	_fire_timer += delta

	# Calculate fire rate based on weapon resource
	var fire_rate: float = weapon.current_weapon.attack_duration

	while _fire_timer >= fire_rate:
		_fire_timer -= fire_rate
		_fire_bullet()

	# Check if attack duration has expired
	if weapon.animation_player.current_animation_position >= weapon.current_weapon.attack_duration:
		pass

func _fire_bullet() -> void:
	var fire_direction: Vector3 = _calculate_spiral_direction()
	var origin: Vector3         = weapon.global_transform * attack_origin
	var end: Vector3    = origin + fire_direction * max_range

	var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end)
	params.collide_with_areas = true
	params.collide_with_bodies = true

	var result: Dictionary = weapon.get_world_3d().direct_space_state.intersect_ray(params)
	if result:
		process_hit(result)

	# Update spiral pattern
	_current_angle += spiral_spread
	_angle_direction *= -1

func _calculate_spiral_direction() -> Vector3:
	var base_forward: Vector3  = weapon.global_transform.basis * Vector3.FORWARD
	var rotation_axis: Vector3 = weapon.global_transform.basis.y
	var angle_rad: float       = deg_to_rad(_current_angle * _angle_direction)
	return base_forward.rotated(rotation_axis, angle_rad).normalized()
