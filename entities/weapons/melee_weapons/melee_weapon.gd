class_name MeleeWeapon
extends Node3D

@export var animation_player: AnimationPlayer
@export var current_weapon: MeleeWeaponResource
@export var hit_mask: int = 2
@export var ray_length: float = 10 # Length of the raycast check

var attacking: bool = false:
	set(value):
		hit_targets_this_swing.clear()
		attacking = value

var hit_targets_this_swing: Array[Node] = []

@onready var hit_check_point: Marker3D = $HitCheckPoint
@onready var weapon_hit_box : Area3D = $WeaponHitBox

func _physics_process(_delta: float) -> void:
	if attacking:
		_check_for_hit()


func _check_for_hit() -> void:
	if not hit_check_point or not weapon_hit_box:
		printerr("MeleeWeapon: HitCheckPoint or WeaponHitBox node not found!")
		return
		
	weapon_hit_box.collision_layer = 0
	weapon_hit_box.collision_mask = hit_mask

	# Collision shape check 
	var overlapping_bodies := weapon_hit_box.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body is Node3D and not hit_targets_this_swing.has(body):
			hit_targets_this_swing.append(body)
			print("Melee hit (area): ", body.name)
			return

	# Raycast check, fallback if no area hit
	var space_state := get_world_3d().direct_space_state
	if not space_state:
		printerr("MeleeWeapon: Could not get DirectSpaceState!")
		return
	
	var ray_origin: Vector3 = hit_check_point.global_position
	var ray_direction: Vector3 = -global_transform.basis.z.normalized()
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = hit_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		var collider: Node = result.get("collider")
		if collider is Node3D and not hit_targets_this_swing.has(collider):
			hit_targets_this_swing.append(collider)
			print("Melee hit (ray): ", collider.name)

	
