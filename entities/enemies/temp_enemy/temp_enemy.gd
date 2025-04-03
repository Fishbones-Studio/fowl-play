## Enemy: A basic enemy that can take damage and die.
class_name Enemy
extends CharacterBody3D

# TODO: enemy should also use livingentity stat

## Exported Variables
@export var health: int = 100

func _ready() -> void:
	SignalManager.weapon_hit_target.connect(_take_damage)


func _physics_process(_delta: float) -> void:
	move_and_slide()


## Public Methods
func _take_damage(target: PhysicsBody3D, damage: int) -> void:
	print(target)
	if target == self:
		print("Enemy hit!")
		health -= damage
		print("Enemy took %d damage! Remaining health: %d" % [damage, health])

	if health <= 0:
		die()


func die() -> void:
	print("Enemy died!")
	queue_free()
