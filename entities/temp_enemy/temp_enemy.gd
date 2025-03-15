class_name Enemy extends CharacterBody3D

@export var health: int = 100

func take_damage(amount: int):
	health -= amount
	print("Enemy took ", amount, " damage! Remaining health: ", health)
	
	if health <= 0:
		die()

func die():
	print("Enemy died!")
	queue_free()
