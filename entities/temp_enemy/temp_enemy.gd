## Enemy: A basic enemy that can take damage and die.
class_name Enemy
extends CharacterBody3D

const DAMAGE_NUMBERS: PackedScene = preload("uid://b6cnb1t5cixqj")

@export var health: int = 1000

@onready var damage_label: Marker3D = $Marker3D


func _physics_process(_delta: float) -> void:
	move_and_slide()


## Public Methods
func take_damage(amount: int) -> void:
	health -= amount 

	var damage_popup: Node3D = DAMAGE_NUMBERS.instantiate()
	get_parent().add_child(damage_popup)

	## Random spawn location for damage number
	var spawn_position: Vector3 = damage_label.global_position + Vector3(
		randf_range(-damage_popup.horizontal_spread, damage_popup.horizontal_spread),
		randf_range(0, damage_popup.vertical_variance),
		randf_range(-damage_popup.depth_offset, damage_popup.depth_offset)
	)

	damage_popup.global_position = spawn_position
	damage_popup.display_damage(amount)

	if health <= 0:
		die()


func die() -> void:
	print("Enemy died!")
	queue_free()
