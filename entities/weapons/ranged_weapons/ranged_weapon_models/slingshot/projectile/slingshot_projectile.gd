extends RigidBody3D

# After this amount of time, spawn the hazard, regardless of collisions
@export var time_out: float = 2.0
@export var hazard: PackedScene = preload("uid://cw81sd3kyuelj")

var base_damage: int = 0
var firer_entity_stats: LivingEntityStats

var _timer: float = 0.0
var _has_spawned_hazard: bool = false


func _ready() -> void:
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

# This function will be called by the weapon state
func setup_projectile(p_firer_stats: LivingEntityStats, p_damage: int) -> void:
	firer_entity_stats = p_firer_stats
	base_damage = p_damage

	# set the mask layer
	if p_firer_stats.is_player:
		collision_mask = 4
	else:
		collision_mask = 2


func _physics_process(delta: float) -> void:
	if _has_spawned_hazard:
		return # Hazard already spawned, no need to do more

	_timer += delta
	if _timer >= time_out:
		_spawn_hazard()


func _on_body_entered(body: Node) -> void:
	if _has_spawned_hazard:
		return

	print("Projectile collided with: ", body.name)
	_spawn_hazard()


func _spawn_hazard() -> void:
	if _has_spawned_hazard: # Ensure it only spawns once
		return
	_has_spawned_hazard = true

	if not is_instance_valid(hazard):
		push_error("Hazard PackedScene is not set for the projectile!")
		queue_free() # Still clean up the projectile
		return

	var hazard_instance : BaseHazard = hazard.instantiate()

	# Place the hazard at the projectile's current position
	hazard_instance.global_position = self.global_position

	# Add the hazard to the scene tree
	var parent_node = get_parent()
	if is_instance_valid(parent_node):
		parent_node.add_child(hazard_instance)
	else:
		# Fallback to current scene if projectile has no parent
		get_tree().current_scene.add_child(hazard_instance)

	# Pass along the damage info to the hazard
	hazard_instance.damage = base_damage

 	# Remove the projectile after spawning the hazard
	queue_free()
