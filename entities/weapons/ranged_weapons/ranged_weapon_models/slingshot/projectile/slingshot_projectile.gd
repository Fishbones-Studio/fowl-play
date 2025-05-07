extends RigidBody3D

@export var time_out: float = 2.0
@export var invincibility_time: float = 0.1
@export_range(0.01, 2.0, 0.01) var fire_pool_damage_modifier := 0.2
@export var hazard: PackedScene = preload("uid://cw81sd3kyuelj")

var base_damage: int = 0

var _timer: float = 0.0
var _has_spawned_hazard: bool = false

var _invincibility_timer: float = 0.0
var _original_collision_mask: int = 0

@onready var debris_effect : GPUParticles3D = $Debris
@onready var fire_effect : GPUParticles3D = $Fire
@onready var smoke_effect : GPUParticles3D = $Smoke
@onready var egg_model : Node3D = $slingshot_projectile
@onready var cracking_sound : RandomSFXPlayer = $CrackingSound
@onready var exposion_sound : RandomSFXPlayer = $ExplosionSound

func setup_projectile(p_firer_stats: LivingEntityStats, p_damage: int) -> void:
	base_damage = p_damage

	if p_firer_stats.is_player:
		# Set collision_mask to collide with layer 1 (bit 0) AND layer 3 (bit 2)
		_original_collision_mask = (1 << 0) | (1 << 2)
	else:
		# Set collision_mask to collide with layer 1 (bit 0) AND layer 2 (bit 1)
		_original_collision_mask = (1 << 0) | (1 << 1)

	# Start with collisions disabled
	collision_mask = 0
	_invincibility_timer = 0.0

func _physics_process(delta: float) -> void:
	if _has_spawned_hazard:
		return

	# Handle invincibility period
	if collision_mask == 0:
		_invincibility_timer += delta
		if _invincibility_timer >= invincibility_time:
			collision_mask = _original_collision_mask

	_timer += delta
	if _timer >= time_out and is_inside_tree():
		_spawn_hazard()

func _on_body_entered(body: Node) -> void:
	# Ignore collisions during invincibility
	if _invincibility_timer < invincibility_time:
		return
		
	cracking_sound.play_random()
	if _has_spawned_hazard:
		return

	if not (body is Enemy or body is ChickenPlayer):
		return

	if not is_inside_tree():
		return

	print("Projectile collided with: ", body.name)
	SignalManager.weapon_hit_target.emit(body, base_damage, DamageEnums.DamageTypes.NORMAL)
	_spawn_hazard()
	
func _explode() -> void:
	# Stop all movement and collisions
	collision_layer = 0
	collision_mask = 0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	call_deferred("set_contact_monitor", false)
	set_freeze_enabled(FREEZE_MODE_STATIC)

	egg_model.hide()
	exposion_sound.play_random()

	debris_effect.emitting = true
	fire_effect.emitting = true
	smoke_effect.emitting = true


func _spawn_hazard() -> void:
	if _has_spawned_hazard:
		return
	_has_spawned_hazard = true
	
	_explode()

	if not is_inside_tree():
		print("Not in tree, aborting hazard spawn.")
		_queue_free_when_particles_done()
		return

	if not is_instance_valid(hazard):
		push_error("Hazard PackedScene is not set for the projectile!")
		_queue_free_when_particles_done()
		return

	var hazard_instance: BaseHazard = hazard.instantiate()

	var parent_node: Node = get_parent()
	var scene_tree: SceneTree = get_tree()

	if is_instance_valid(parent_node):
		parent_node.add_child(hazard_instance)
	else:
		scene_tree.current_scene.add_child(hazard_instance)
	hazard_instance.global_position = global_position
	hazard_instance.damage = base_damage * fire_pool_damage_modifier

	_queue_free_when_particles_done()

func _queue_free_when_particles_done() -> void:
	# Wait until all particles are finished, then queue_free
	await _all_particles_finished()
	if is_inside_tree():
		queue_free()

func _all_particles_finished() -> void:
	# Wait for all three particles to finish
	var effects: Array[Variant] = [debris_effect, fire_effect, smoke_effect]
	for effect in effects:
		if effect.emitting:
			await effect.finished
