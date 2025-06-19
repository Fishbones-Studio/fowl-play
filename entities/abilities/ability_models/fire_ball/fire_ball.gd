extends Ability

## The movement speed of the fireball
@export var travel_speed: float = 5.0
## The duration before the fireball is automatically destroyed
@export var lifetime: float = 6.0
## The time interval between each instance of damage while a target remains inside the fireball
@export var damage_interval: float = 0.5
## The maximum scale factor the fireball can grow to over its lifetime
@export_range(1, 2, 0.01) var scale_factor: float = 2.0

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return ((stats.current_stamina / stats.max_stamina) * 100) / 2

var _is_active: bool = false
var _travel_direction: Vector3
var _current_damage: float = 0.0
var _remaining_lifetime: float = 0.0
var _active_bodies: Dictionary[int, int] = {}

@onready var hit_area: Area3D = %HitArea
@onready var mesh_instance: Node3D = %FireballMesh
@onready var collision_shape: CollisionShape3D = %CollisionShape3D
@onready var spark: GPUParticles3D = %Spark


func activate(_force_activate: bool = false) -> void:
	# Ignore the parent's transform
	# This ensures the fireball moves independently, without being affected by the player's movement
	top_level = true
	global_position = ability_holder.global_position + (Vector3.UP * 2) # Move Y up by 2, so it spawns a bit centered

	ability_holder.stats.current_stamina -= damage

	_toggle_collision_masks(true, hit_area)

	_is_active = true
	sound_effect.play()
	_travel_direction = -ability_holder.global_basis.z.normalized()
	_current_damage = damage
	_remaining_lifetime = lifetime
	_active_bodies.clear()

	mesh_instance.visible = true
	spark.emitting = true

	if ability_holder is ChickenPlayer:
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	_is_active = false


func _physics_process(delta: float) -> void:
	if not _is_active:
		_reset_ability()
		return

	if _active_bodies.size() > 0:
		_apply_continuous_damage()

	_remaining_lifetime -= delta

	var scale_increment: Vector3 = mesh_instance.scale + Vector3.ONE * delta * scale_factor

	# Increase the current damage depending on remaining lifetime and the speed it travels at
	# As the remaining lifetime decreases, the damage will ramp up
	_current_damage += damage * ((1.0 + (_remaining_lifetime / lifetime)) * delta) / (travel_speed * 2)

	mesh_instance.scale = scale_increment
	collision_shape.scale = scale_increment
	spark.scale = scale_increment

	if _remaining_lifetime <= 0:
		_reset_ability()

	global_position += _travel_direction * travel_speed * delta
	look_at(global_position + _travel_direction)


func _on_hit_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		var id: int = body.get_instance_id()
		if not _active_bodies.has(id):
			_active_bodies[id] = Time.get_ticks_msec()

			_apply_damage(body)


func _on_hit_area_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		var id: int = body.get_instance_id()
		_active_bodies.erase(id)


func _apply_continuous_damage() -> void:
	var current_time: int = Time.get_ticks_msec()

	for id in _active_bodies:
		var body: CharacterBody3D = instance_from_id(id)

		if not is_instance_valid(body):
			_active_bodies.erase(body)
			continue

		# Check if the elapsed time has passed the interval
		if (current_time - _active_bodies[id]) >= (damage_interval * 1000):
			_active_bodies[id] = current_time

			# Only apply damage if body is Player of Enemy
			_apply_damage(body)


func _apply_damage(body: CharacterBody3D) -> void:
	if body.collision_layer == 2 or body.collision_layer == 4:
		SignalManager.weapon_hit_target.emit(body, _current_damage, DamageEnums.DamageTypes.NORMAL)


func _reset_ability() -> void:
	top_level = false
	_is_active = false
	mesh_instance.visible = false
	spark.emitting = false

	mesh_instance.scale = Vector3.ONE
	collision_shape.scale = Vector3.ONE
	spark.scale = Vector3.ONE

	_toggle_collision_masks(false, hit_area)
