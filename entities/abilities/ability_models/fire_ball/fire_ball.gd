extends Ability

@export var travel_speed: float = 6.0
@export var lifetime: float = 8.0
@export_range(1, 20, 0.1) var scale_factor: float = 1.8

var damage: float:
	get:
		var stats: LivingEntityStats = ability_holder.stats
		return stats.attack * 2.5

var _is_active: bool = false
var _travel_direction: Vector3
var _remaining_lifetime: float = 0.0

@onready var hit_area: Area3D = %HitArea
@onready var mesh_instance: MeshInstance3D = %MeshInstance3D
@onready var collision_shape: CollisionShape3D = %CollisionShape3D
@onready var cpu_particles: CPUParticles3D = %CPUParticles3D


func activate() -> void:
	# Ignore the parent's transform
	# This ensures the fireball moves independently, without being affected by the player's movement
	top_level = true
	global_position = ability_holder.global_position + (Vector3.UP * 2) # Move Y up by 2, so it spawns a bit centered

	_toggle_collision_masks(true)

	_is_active = true
	_travel_direction = -ability_holder.global_basis.z.normalized()
	_remaining_lifetime = lifetime

	mesh_instance.visible = true
	cpu_particles.emitting = true

	if ability_holder == ChickenPlayer:
		SignalManager.activate_item_slot.emit(current_ability)
		SignalManager.cooldown_item_slot.emit(current_ability, cooldown_timer.wait_time, true)

	cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	_is_active = false


func _physics_process(delta: float) -> void:
	if not _is_active:
		return

	_remaining_lifetime -= delta

	var scale_increment: Vector3 = mesh_instance.scale + Vector3.ONE * delta * scale_factor

	mesh_instance.scale = scale_increment
	collision_shape.scale = scale_increment
	cpu_particles.scale = scale_increment

	if _remaining_lifetime <= 0:
		_reset_ability()

	global_position += _travel_direction * travel_speed * delta


func _on_hit_area_body_entered(body: Node3D) -> void:
	if body.collision_layer == 2: # Player
		SignalManager.weapon_hit_target.emit(body, damage, DamageEnums.DamageTypes.NORMAL)
	if body.collision_layer == 4: # Enemy
		SignalManager.weapon_hit_target.emit(body, damage, DamageEnums.DamageTypes.NORMAL)


func _reset_ability() -> void:
	top_level = false
	_is_active = false
	mesh_instance.visible = false
	cpu_particles.emitting = false
	mesh_instance.scale = Vector3.ONE
	collision_shape.scale = Vector3.ONE
	cpu_particles.scale = Vector3.ONE
	_toggle_collision_masks(false)


func _toggle_collision_masks(toggle: bool) -> void:
	if ability_holder.collision_layer == 2: # Player
		hit_area.set_collision_mask_value(3, toggle)
	if ability_holder.collision_layer == 4: # Enemy
		hit_area.set_collision_mask_value(2, toggle)

	hit_area.set_collision_mask_value(1, toggle) # World
