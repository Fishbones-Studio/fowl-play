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


func _on_hazard_area_body_exited(_body: Node3D) -> void:
	# Overwrite in child class
	pass
