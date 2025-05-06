extends RigidBody3D

@export var time_out: float = 2.0
@export var hazard: PackedScene = preload("uid://cw81sd3kyuelj")

var base_damage: int = 0
var firer_entity_stats: LivingEntityStats

var _timer: float = 0.0
var _has_spawned_hazard: bool = false

func setup_projectile(p_firer_stats: LivingEntityStats, p_damage: int) -> void:
	firer_entity_stats = p_firer_stats
	base_damage = p_damage
	
	# TODO: set up collision layer and fix on body entered

func _physics_process(delta: float) -> void:
	if _has_spawned_hazard:
		return

	_timer += delta
	if _timer >= time_out and is_inside_tree():
		_spawn_hazard()

func _on_body_entered(body: Node) -> void:
	if _has_spawned_hazard:
		return

	if not is_inside_tree():
		return

	print("Projectile collided with: ", body.name)
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
	hazard_instance.global_position = global_position

	var parent_node: Node = get_parent()
	var scene_tree: SceneTree = get_tree()

	queue_free()

	if is_instance_valid(parent_node):
		parent_node.add_child(hazard_instance)
	else:
		scene_tree.current_scene.add_child(hazard_instance)

	hazard_instance.damage = base_damage
