class_name EnemyBTAction
extends BTAction


func _set_agent_avoidance() -> void:
	var shape: Shape3D = agent.shape.shape
	if shape is CapsuleShape3D:
		agent.nav.radius = shape.radius
		agent.nav.height = shape.height
	if shape is SphereShape3D:
		agent.nav.radius = shape.radius
		agent.nav.height = shape.radius
	if shape is BoxShape3D:
		agent.nav.radius = shape.size.x / 2.0
		agent.nav.height = shape.size.y / 2.0
