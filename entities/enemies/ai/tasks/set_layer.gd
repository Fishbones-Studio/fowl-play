@tool
extends BTAction

@export_flags_3d_physics var layer: int = 4 # Default enemy layer value


# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Layer ➜ %d" % layer


func _enter() -> void:
	if agent is CharacterBody3D:
		agent.collision_layer = layer


func _tick(delta: float) -> Status:
	if not agent is CharacterBody3D:
		return FAILURE
	if agent.collision_layer != layer:
		return RUNNING

	return SUCCESS
