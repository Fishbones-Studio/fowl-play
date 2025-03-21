class_name BaseHazard
extends Node

@export var damage: int = 10


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body is ChickenPlayer:
		SignalManager.hurt_player.emit(damage)
	elif body is Enemy:
		body.take_damage(damage)


func _on_hazard_area_body_exited(_body: Node3D) -> void:
	# Overwrite in child class
	pass
