## Enemy: A basic enemy that can take damage and die.
class_name Enemy extends CharacterBody3D

## Exported Variables
@export var health: int = 100

## Public Methods
func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took %d damage! Remaining health: %d" % [amount, health])
	
	if health <= 0:
		die()

func die() -> void:
	print("Enemy died!")
	queue_free()
