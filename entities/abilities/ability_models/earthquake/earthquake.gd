extends Ability

@export var descent_velocity: float = -50.0
@export var initial_knockback_force: float = 20
@export var knockback_force_upwards: float = 5
@export var quake_interval: float = 0.5  # Time between quake pulses
@export var quake_damage_increase: float = 0.2  # Damage multiplier per quake
@export var quake_radius_increase: float = 0.5  # Radius multiplier per quake
@export var max_quakes: int = 3  # Maximum number of quake pulses

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return (stats.weight * stats.defense * 0.5) / max_quakes

var _current_quake_count: int = 0
var _current_damage: float = 0.0
var _current_knockback: float = 0.0
var _hit_bodies: Array = []  # Track already hit bodies per activation

@onready var camera: FollowCamera = get_tree().get_first_node_in_group("FollowCamera")
@onready var quake_timer: Timer = $QuakeTimer
@onready var hit_area: Area3D = $HitArea
@onready var cpu_particles: CPUParticles3D = %CPUParticles3D
@onready var collision_shape: CollisionShape3D = %CollisionShape3D


func activate() -> void:
	if ability_holder.is_on_floor():
		print("Cannot perform %s while on the ground." % name)
		return

	# Initialize quake properties
	_current_quake_count = 0
	_current_damage = damage
	_current_knockback = initial_knockback_force
	_hit_bodies.clear()

	_toggle_collision_masks(true)

	ability_holder.velocity = Vector3(0, descent_velocity, 0)

	if ability_holder == ChickenPlayer:
		SignalManager.activate_item_slot.emit(current_ability)
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _physics_process(delta: float) -> void:
	if ability_holder.is_on_floor() and on_cooldown and quake_timer.is_stopped() and _current_quake_count == 0:
		_start_quake_sequence()


func _start_quake_sequence() -> void:
	_pulse_quake()

	quake_timer.wait_time = quake_interval


func _pulse_quake() -> void:
	# Damage and knockback all bodies in area
	for body in hit_area.get_overlapping_bodies():
		if body in _hit_bodies:
			continue

		if body.collision_layer == 2 or body.collision_layer == 4:  # Player or Enemy
			SignalManager.weapon_hit_target.emit(body, _current_damage, DamageEnums.DamageTypes.NORMAL)
			_apply_knockback(body)
			_hit_bodies.append(body)

	print("EARTHQUAKE")
	if camera:
		camera.apply_shake(1.0)

	collision_shape.scale = Vector3.ONE * (1.0 + (_current_quake_count * quake_radius_increase))
	cpu_particles.scale = collision_shape.scale
	cpu_particles.emitting = true

	# Damage calculation
	_current_damage = damage * (1.0 + (_current_quake_count * quake_damage_increase))
	_current_knockback = initial_knockback_force * (1.0 + (_current_quake_count * quake_damage_increase))

	# End sequence if max quakes reached
	_current_quake_count += 1
	if _current_quake_count < max_quakes:
		quake_timer.start()
	else:
		_reset_ability()

	_hit_bodies.clear()


func _reset_ability() -> void:
	# Reset size
	collision_shape.scale = Vector3.ONE
	cpu_particles.scale = Vector3.ONE

	# Reset vertical velocity
	ability_holder.velocity.y = 0
	_toggle_collision_masks(false)

	if ability_holder == ChickenPlayer:
		SignalManager.deactivate_item_slot.emit(current_ability)


func _apply_knockback(body: Node3D) -> void:
	if body is CharacterBody3D:
		var dir: Vector3 = ability_holder.global_position.direction_to(body.global_position)
		var knockback: Vector3 = Vector3(
			dir.x * _current_knockback,
			dir.y * knockback_force_upwards,
			dir.z * _current_knockback
		)
		if body is ChickenPlayer:
			SignalManager.player_transition_state.emit(PlayerEnums.PlayerStates.HURT_STATE, {
			"knockback": knockback,
			"immobile_time": 0.5,
		})
		elif body is Enemy:
			body.velocity = knockback * ability_holder.stats.weight


func _toggle_collision_masks(toggle: bool) -> void:
	if ability_holder.collision_layer == 2:  # Player
		hit_area.set_collision_mask_value(4, toggle)
	if ability_holder.collision_layer == 4:  # Enemy
		hit_area.set_collision_mask_value(2, toggle)
	hit_area.set_collision_mask_value(1, toggle)  # World
