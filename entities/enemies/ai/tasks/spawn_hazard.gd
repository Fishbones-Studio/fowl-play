@tool
extends BTAction

## Resource for the hazard
@export var hazard_resource: PackedScene


func _generate_name() -> String:
	return "Spawn hazard"


func _tick(_delta: float) -> Status:
	return SUCCESS if _spawn_hazard() else FAILURE


func _spawn_hazard() -> bool:
	if not hazard_resource.can_instantiate():
		return false

	var hazard: BaseHazard = hazard_resource.instantiate()

	if not hazard:
		return false

	hazard.spawner = agent
	agent.get_tree().current_scene.add_child(hazard)
	hazard.global_position = agent.global_position

	return true
