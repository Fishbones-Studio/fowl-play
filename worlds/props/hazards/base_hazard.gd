## BazeHazard serves as a base class for all hazards in the game.
##
## It handles the basic functionality of detecting when a body enters the hazard area
## and applying damage to the player or enemy. Child classes can extend this functionality

class_name BaseHazard
extends Node

@export var damage: int = 10

## Dictionary to track active bodies and their entry time
var active_bodies: Dictionary[PhysicsBody3D, int] = {}


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body is ChickenPlayer:
		SignalManager.hurt_player.emit(damage)
	elif body is Enemy:
		body.take_damage(damage)


## Overwrite in child class
func _on_hazard_area_body_exited(_body: Node3D) -> void:

	pass
