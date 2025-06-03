class_name MeleeWeapon
extends Node3D

# Used in the state machine
@export var animation_player: AnimationPlayer
@export var current_weapon: MeleeWeaponResource
@export var hit_mask: int = 2

var attacking: bool = false:
	set(value):
		attacking = value
		hit_targets_this_swing.clear()

var hit_targets_this_swing: Array[Node] = []
var entity_stats: LivingEntityStats
var enable_stun: bool = true

@onready var weapon_hit_box: Area3D = $WeaponHitBox
@onready var weapon_attack_sfx: AudioStreamPlayer = $WeaponAttackSFX


func _physics_process(_delta: float) -> void:
	
	if attacking:
		_check_for_hit()


func _check_for_hit() -> void:
	if not weapon_hit_box:
		push_error("MeleeWeapon: WeaponHitBox node not found!")
		return

	weapon_hit_box.collision_mask = hit_mask

	var overlapping_bodies: Array [Node3D] = weapon_hit_box.get_overlapping_bodies()

	for body in overlapping_bodies:
		if body is Node3D and not hit_targets_this_swing.has(body):
			hit_targets_this_swing.append(body)
			return


## Funtion to call from animation tracks
func set_attacking(attacking_value: bool) -> void:
	attacking = attacking_value


func weapon_hit_effect(_body: CharacterBody3D) -> void:
	pass
