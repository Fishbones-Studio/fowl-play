extends Ability

@export var descent_velocity: float = -25.0
@export var initial_knockback_force: float = 9.0
@export var knockback_force_upwards: float = 5.0
@export var quake_interval: float = 0.5  # Time between quake pulses
@export var quake_damage_increase: float = 0.5  # Damage multiplier per quake
@export var quake_radius_increase: float = 0.5  # Radius multiplier per quake
@export var max_quakes: int = 3  # Maximum number of quake pulses

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return (stats.weight * stats.defense * 0.5) / max(1, max_quakes)

var _current_quake_count: int = 0
var _current_damage: float = 0.0
var _current_knockback: float = 0.0
var _hit_bodies: Array = []  # Track already hit bodies per activation
var _stop_moving: bool = false
var _particles: Array[GPUParticles3D] = []

@onready var camera: FollowCamera = get_tree().get_first_node_in_group("FollowCamera")
@onready var quake_timer: Timer = $QuakeTimer
@onready var hit_area: Area3D = $HitArea
@onready var collision_shape: CollisionShape3D = %CollisionShape3D



func _ready() -> void:
	for particle in hit_area.get_children():
		if particle is GPUParticles3D:
			_particles.append(particle)


func activate() -> void:
	if ability_holder.is_on_floor():
		print("Cannot perform %s while on the ground." % name)
		return

	# Initialize quake properties
	_current_quake_count = 0
	_current_damage = damage
	_current_knockback = initial_knockback_force
	_hit_bodies.clear()

	_toggle_collision_masks(true, hit_area)

	ability_holder.velocity = Vector3(0, descent_velocity, 0)

	if ability_holder == ChickenPlayer:
		SignalManager.activate_item_slot.emit(current_ability)
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _physics_process(_delta: float) -> void:
	if ability_holder.is_on_floor() and on_cooldown and quake_timer.is_stopped() and _current_quake_count == 0:
		_start_quake_sequence()
		_stop_moving = true
	if _stop_moving:
		ability_holder.velocity = Vector3.ZERO


func _start_quake_sequence() -> void:
	quake_timer.wait_time = quake_interval

	_pulse_quake()


func _pulse_quake() -> void:
	# Damage and knockback all bodies in area
	for body in hit_area.get_overlapping_bodies():
		if body in _hit_bodies:
			continue

		if body.collision_layer == 2 or body.collision_layer == 4:  # Player or Enemy
			SignalManager.weapon_hit_target.emit(body, _current_damage, DamageEnums.DamageTypes.NORMAL)
			_apply_knockback(body)
			_hit_bodies.append(body)

	_particles[_current_quake_count].emitting = true

	if camera:
		camera.apply_shake(1.0)

	# End sequence if max quakes reached
	_current_quake_count += 1
	if _current_quake_count < max_quakes:
		var scale_factor: float = 1.0 + (_current_quake_count * quake_radius_increase)

		collision_shape.scale = Vector3.ONE * scale_factor
		_particles[_current_quake_count].process_material.set("scale_min", scale_factor)
		_current_knockback = _current_knockback * scale_factor

		_current_damage = damage * (1.0 + (_current_quake_count * quake_damage_increase))
		quake_timer.start()
	else:
		_reset_ability()
		_stop_moving = false

	_hit_bodies.clear()


func _reset_ability() -> void:
	# Reset size
	collision_shape.scale = Vector3.ONE
	for particle in _particles:
		particle.scale = Vector3.ONE

	# Reset vertical velocity
	ability_holder.velocity.y = 0
	_toggle_collision_masks(false, hit_area)

	if ability_holder == ChickenPlayer:
		SignalManager.deactivate_item_slot.emit(current_ability)


func _apply_knockback(body: Node3D) -> void:
	if body is CharacterBody3D:
		var dir: Vector3 = ability_holder.global_position.direction_to(body.global_position)
		var knockback: Vector3 = Vector3(
			dir.x * _current_knockback,
			abs(dir.y * knockback_force_upwards),
			dir.z * _current_knockback
		)
		if body is ChickenPlayer:
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.HURT_STATE, {
			"knockback": knockback,
			"immobile_time": 0.5,
		})
		elif body is Enemy:
			body.velocity = knockback * ability_holder.stats.weight
