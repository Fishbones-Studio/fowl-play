## Enemy: A basic enemy that can take damage and die.
class_name Enemy
extends CharacterBody3D
@onready var marker_3d: Marker3D = $Marker3D

## Exported Variables
@export var health: int = 100
var dmg_numbers
const DAMAGE_NUMBERS = preload("res://ui/damage_number/damage_numbers.tscn")


func _physics_process(_delta: float) -> void:
	move_and_slide()


## Public Methods
func take_damage(amount: int) -> void:
	health -= amount 
	dmg_numbers = DAMAGE_NUMBERS.instantiate()
	get_parent().add_child(dmg_numbers)
	dmg_numbers.global_position = marker_3d.global_position
	dmg_numbers.set_and_play(amount)
	if health <= 0:
		die()


func die() -> void:
	print("Enemy died!")
	queue_free()
