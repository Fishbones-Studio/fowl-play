extends RigidBody3D

@export var time_out: float = 2.0
@export_range (0.01, 2.0, 0.01) var fire_pool_damage_modifier = 0.1
@export var hazard: PackedScene = preload("uid://cw81sd3kyuelj")

var base_damage: int = 0

var _timer: float = 0.0
var _has_spawned_hazard: bool = false

func setup_projectile(p_firer_stats: LivingEntityStats, p_damage: int) -> void:
	print("Setting up projectile with %d with collsion mask" % p_damage)
	base_damage = p_damage
	
	if p_firer_stats.is_player:
		# Set collision_mask to collide with layer 1 (bit 0) AND layer 3 (bit 2)
		collision_mask = (1 << 0) | (1 << 2)
	else:
		# Set collision_mask to collide with layer 1 (bit 0) AND layer 2 (bit 1)
		collision_mask = (1 << 0) | (1 << 1)
		
	print("Set collision mask to %d" % collision_mask)


func _physics_process(delta: float) -> void:
	if _has_spawned_hazard:
		return

	_timer += delta
	if _timer >= time_out and is_inside_tree():
		_spawn_hazard()

func _on_body_entered(body: Node) -> void:
	print("Colliding with body" + body.name)
	if !(body is Enemy or body is ChickenPlayer) : return
	
	if _has_spawned_hazard:
		return

	if not is_inside_tree():
		return

	print("Projectile collided with: ", body.name)
	SignalManager.weapon_hit_target.emit(body, base_damage, DamageEnums.DamageTypes.NORMAL)
	_spawn_hazard()

func _spawn_hazard() -> void:
	if _has_spawned_hazard:
		return
	_has_spawned_hazard = true

	if not is_inside_tree():
		print("Not in tree, aborting hazard spawn.")
		queue_free()
		return

	if not is_instance_valid(hazard):
		push_error("Hazard PackedScene is not set for the projectile!")
		queue_free()
		return

	var hazard_instance: BaseHazard = hazard.instantiate()

	var parent_node: Node = get_parent()
	var scene_tree: SceneTree = get_tree()

	queue_free()

	if is_instance_valid(parent_node):
		parent_node.add_child(hazard_instance)
	else:
		scene_tree.current_scene.add_child(hazard_instance)
	hazard_instance.global_position = global_position
	hazard_instance.damage = base_damage * fire_pool_damage_modifier
