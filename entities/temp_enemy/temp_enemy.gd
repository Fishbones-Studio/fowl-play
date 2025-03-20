## Enemy: A basic enemy that can take damage and die.
class_name Enemy extends CharacterBody3D



## Exported Variables
@export var health: int = 100
@export var damage_to_player: int = 10
@export var hit_area: Area3D



## Public Methods
func take_damage(amount: int) -> void:	
	health -= amount
	print("Enemy took %d damage! Remaining health: %d" % [amount, health])
	
	if health <= 0:
		die()

func die() -> void:
	print("Enemy died!")
	queue_free()


func attack_player():
	var bodies = hit_area.get_overlapping_bodies()
	
	
	for body in bodies:
		if body is ChickenPlayer:
			SignalManager.hurt_player.emit(damage_to_player)


func _on_area_3d_body_entered(body: Node3D) -> void:
	attack_player()
