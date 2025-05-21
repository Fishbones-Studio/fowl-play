## BazeHazard serves as a base class for all hazards in the game.
##
## It handles the basic functionality of detecting when a body enters the hazard area
## and applying damage to the player or enemy. Child classes can extend this functionality
class_name BaseHazard
extends Node3D

@export var damage: int = 10

## Dictionary to track active bodies and their entry time
var active_bodies: Dictionary[int, int] = {} ## Dictionary[body_id, entry_time]. By using id (int), we prevent errors after the body no longer existing.
var bodies_to_remove: Array[int] = [] ## List of bodies to remove after iteration. By using id (int), we prevent errors after the body no longer existing.


func _process(_delta: float) -> void:
	erase_invalid_bodies()


func _on_hazard_area_body_entered(body: Node3D) -> void:
	if body.collision_layer in [2, 4]:
		if body is Enemy and body.type == EnemyEnums.EnemyTypes.BOSS:
			# Boss enemies are immune to hazard damage
			return

		SignalManager.weapon_hit_target.emit(body, damage, DamageEnums.DamageTypes.TRUE)


## Overwrite in child class
func _on_hazard_area_body_exited(_body: Node3D) -> void:
	pass


# Erase invalid entries from the active_bodies dictionary
func erase_invalid_bodies() -> void:
	# Erase invalid entries after iteration
	for id in bodies_to_remove:
		active_bodies.erase(id)
	bodies_to_remove.clear()
