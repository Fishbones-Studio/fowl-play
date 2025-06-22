@tool
extends BTCondition

## distance to look up (including entity height)
@export var check_distance: float = 4.0
@export_flags_3d_physics var player_layer: int = 2


func _generate_name() -> String:
	return "PlayerOnTop ➜ check_distance: %.1f" % check_distance


func _tick(_delta: float) -> Status:
	if not agent.visible:
		return FAILURE

	var result: bool = _is_player_on_top()
	return SUCCESS if result else FAILURE 


func _is_player_on_top() -> bool:
	var space_state: PhysicsDirectSpaceState3D = agent.get_world_3d().direct_space_state
	var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

	params.from = agent.global_position
	params.to = agent.global_position + Vector3.UP * check_distance
	params.collision_mask = player_layer

	var hit: Dictionary = space_state.intersect_ray(params)
	return hit and hit["collider"] is ChickenPlayer
