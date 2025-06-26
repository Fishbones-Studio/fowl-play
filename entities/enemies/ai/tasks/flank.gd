@tool
extends BTAction

enum Type {
	DEPARTURE,
	ARRIVAL,
}

enum State {
	IDLE,
	DEPARTURE_TELEGRAPHING,
	FINDING_POSITION,
	ARRIVAL_TELEGRAPHING,
	PERFORMING_FLANK,
	FINISHED
}

## Blackboard variable that stores our target
@export var target_var: StringName = &"target"
## Distance behind target to teleport
@export var flank_distance: float = 2.0
## Vertical offset to prevent ground clipping
@export var vertical_offset: float = 0.0
## Radius to check for clear space
@export_range(0.1, 5.0, 0.1) var clearance_radius: float = 1.0
## Telegraph that appears before agent disappears
@export var departure_telegraph: bool = true
## Telegraph that appears before agent appears
@export var arrival_telegraph: bool = true
## Time to wait during departure
@export var telegraph_departure_time: float = 0.5
## Time to wait during arrival
@export var telegraph_arrival_time: float = 1.0
@export_range(0.1, 10.0, 0.1) var telegraph_scale: float = 1.5

var _current_state: State = State.IDLE
var _flank_position: Vector3 = Vector3.ZERO
var _current_telegraph_instance: GPUParticles3D = null
var _space_state: PhysicsDirectSpaceState3D = null
var _clearance_shape: Shape3D = null
var _telegraph_resource: PackedScene = preload("uid://bi7ih1it2v747")
var _half_timer: SceneTreeTimer = null
var _end_timer: SceneTreeTimer = null


# Display a customized name (requires @tool).
func _generate_name() -> String:
	var name_parts: Array[String] = ["Flank"]

	if target_var:
		name_parts.append(LimboUtility.decorate_var(target_var))

	if flank_distance != 2.0:
		name_parts.append("flank_distance: %.1f" % flank_distance)

	if vertical_offset > 0:
		name_parts.append("vertical_offset: %.1f" % vertical_offset)

	if clearance_radius != 1.0:
		name_parts.append("clearance_radius: %.1f" % clearance_radius)

	return " ➜ ".join(name_parts) if name_parts.size() > 1 else "Flank"


func _enter() -> void:
	# Initialize state variables
	_current_state = State.IDLE
	_flank_position = Vector3.ZERO
	_cleanup_telegraph() # Ensure no lingering telegraph from previous runs

	_space_state = agent.get_world_3d().direct_space_state
	if not _space_state:
		_log_error("PhysicsDirectSpaceState3D not available!")
		_current_state = State.FINISHED # Force failure state
		return

	_clearance_shape = SphereShape3D.new()
	_clearance_shape.radius = clearance_radius
	if not _clearance_shape:
		_log_error("Failed to create clearance shape!")
		_current_state = State.FINISHED # Force failure state
		return
	

	if departure_telegraph:
		var offset: float = 0.0
		var agent_shape_node: CollisionShape3D = agent.shape

		if agent_shape_node and agent_shape_node.shape:
			var agent_shape: Shape3D = agent_shape_node.shape
			if agent_shape is SphereShape3D or agent_shape is CapsuleShape3D:
				offset = agent_shape.height / 2.0
			elif agent_shape is BoxShape3D:
				offset = agent_shape.size.y / 2.0
			else:
				_log_warning("Agent's shape is not Sphere/Capsule/Box.")
		else:
			_log_warning("Agent's CollisionShape3D or its shape not found")

		# Agent visibility handled in _on_telegraph_halfway
		_current_state = State.DEPARTURE_TELEGRAPHING
		_create_telegraph_effect(Type.DEPARTURE, Vector3(
				agent.global_position.x,
				agent.global_position.y + offset,
				agent.global_position.z,
			))
	else:
		# If no departure telegraph, go straight to finding position
		_current_state = State.FINDING_POSITION
		agent.visible = false # Agent becomes invisible immediately if no telegraph


func _tick(_delta: float) -> Status:
	var target: ChickenPlayer = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		_log_error("Target not found or invalid during FINDING_POSITION.")
		return FAILURE

	match _current_state:
		State.IDLE:
			# Should not happen often, but acts as a safeguard.
			# _enter() transitions from IDLE.
			return RUNNING

		State.DEPARTURE_TELEGRAPHING:
			# We are waiting for the departure telegraph timer.
			# The _on_telegraph_finished signal or _on_telegraph_halfway handles state transition.
			return RUNNING

		State.FINDING_POSITION:
			_flank_position = _get_safe_flank_position(target)
			if _flank_position == Vector3.INF:
				_log_error("Failed to find a safe flank position.")
				return FAILURE

			if arrival_telegraph:
				_current_state = State.ARRIVAL_TELEGRAPHING
				_create_telegraph_effect(Type.ARRIVAL, _flank_position)
				agent.apply_gravity = false # Disable gravity while waiting for arrival
			else:
				_current_state = State.PERFORMING_FLANK
				# Agent becomes visible and teleports immediately
				agent.global_position = _flank_position
				agent.velocity = Vector3.ZERO
				agent.visible = true
				agent.apply_gravity = true
				_current_state = State.FINISHED # Move to finished after immediate flank

			return RUNNING # Continue processing in next tick for state change

		State.ARRIVAL_TELEGRAPHING:
			# We are waiting for the arrival telegraph timer.
			# The _on_telegraph_finished signal or _on_telegraph_halfway handles state transition.
			return RUNNING

		State.PERFORMING_FLANK:
			# This state is used for the instant teleport part if no arrival telegraph.
			# It transitions to FINISHED directly.
			_current_state = State.FINISHED
			return RUNNING # Will transition to SUCCESS in the very next tick

		State.FINISHED:
			agent.look_at(Vector3(
				target.global_position.x,
				agent.global_position.y,
				target.global_position.z
			))
			# Action is complete, return SUCCESS
			return SUCCESS

	return RUNNING # Default return for safety, though states should cover all cases


func _exit() -> void:
	# Always clean up any active timers or instances when the action exits
	_cleanup_telegraph()

	# Ensure agent state is reset
	agent.visible = true
	agent.apply_gravity = true # Ensure gravity is re-enabled
	agent.velocity = Vector3.ZERO # Stop any lingering velocity

	# Reset internal state to be ready for next _enter
	_current_state = State.IDLE
	_flank_position = Vector3.ZERO


func _get_safe_flank_position(target: ChickenPlayer) -> Vector3:
	var base_dir: Vector3 = -target.global_basis.z.normalized()
	var test_angles: Array[float] = [180.0, 90.0, -90.0, 45.0, -45.0, 0.0]

	test_angles.shuffle()

	for angle in test_angles:
		var rotated_dir: Vector3 = base_dir.rotated(Vector3.UP, deg_to_rad(angle))
		var test_pos: Vector3 = target.global_position + (rotated_dir * flank_distance)
		test_pos.y += vertical_offset

		if _is_position_clear(test_pos):
			return test_pos

	return Vector3.INF # Indicates no safe position found


func _is_position_clear(position: Vector3) -> bool:
	if is_equal_approx(clearance_radius, 0.0):
		push_error("clearance_radius must be > 0 (current: %f)" % clearance_radius)
		return false

	var params: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	params.transform = Transform3D(Basis(), position)
	params.shape_rid = _clearance_shape.get_rid() # Use RID for direct queries
	params.collision_mask = agent.collision_mask
	params.exclude = [agent.get_rid()]

	var results: Array[Dictionary] = _space_state.intersect_shape(params)

	return results.is_empty()


func _create_telegraph_effect(telegraph_type: Type, telegraph_position: Vector3) -> void:
	if not _telegraph_resource:
		_log_error("Telegraph resource is not assigned.")
		_current_state = State.FINISHED # Force failure state
		return

	# Instantiate and assign
	_current_telegraph_instance = _telegraph_resource.instantiate()

	# Handle mesh scaling based on agent's collision shape
	var mesh: Mesh = _current_telegraph_instance.draw_pass_1
	if mesh is SphereMesh:
		var agent_shape_node: CollisionShape3D = agent.shape
		if agent_shape_node and agent_shape_node.shape:
			var agent_shape: Shape3D = agent_shape_node.shape
			if agent_shape is SphereShape3D:
				mesh.radius = agent_shape.radius
				mesh.height = agent_shape.radius
			elif agent_shape is CapsuleShape3D:
				mesh.radius = agent_shape.radius
				mesh.height = agent_shape.radius * 2.0
			elif agent_shape is BoxShape3D:
				mesh.radius = agent_shape.size.x / 2.0
				mesh.height = agent_shape.size.y
			else:
				_log_warning("Agent's shape is not Sphere/Capsule/Box for telegraph scaling.")
		else:
			_log_warning("Agent's CollisionShape3D or its shape not found for telegraph scaling.")

	# Duplicate and modify process material for instance-specific changes
	var material: ParticleProcessMaterial = _current_telegraph_instance.process_material.duplicate()
	var original_scale_min: float = material.scale_min
	material.scale_min = original_scale_min * telegraph_scale # Adjust scale, so it's bigger than enemy model
	_current_telegraph_instance.process_material = material

	# Add to scene tree
	agent.get_parent().add_child(_current_telegraph_instance)
	_current_telegraph_instance.global_position = telegraph_position

	# Configure lifetime and connections
	var total_telegraph_time: float = 0.0
	if telegraph_type == Type.ARRIVAL:
		_current_telegraph_instance.lifetime = telegraph_arrival_time
		total_telegraph_time = telegraph_arrival_time
	elif telegraph_type == Type.DEPARTURE:
		_current_telegraph_instance.lifetime = telegraph_departure_time
		total_telegraph_time = telegraph_departure_time
	_current_telegraph_instance.emitting = true

	# Create a separate timer for the halfway point visibility change
	if _half_timer: 
		if _half_timer.timeout.is_connected(_on_telegraph_halfway):
			_half_timer.timeout.disconnect(_on_telegraph_halfway)
	_half_timer = agent.get_tree().create_timer(_current_telegraph_instance.lifetime * 0.5)
	_half_timer.timeout.connect(_on_telegraph_halfway.bind(telegraph_type), CONNECT_ONE_SHOT)

	# Create a separate timer for the end of the telegraph
	if _end_timer: 
		if _end_timer.timeout.is_connected(_on_telegraph_halfway):
			_end_timer.timeout.disconnect(_on_telegraph_halfway)
	_end_timer = agent.get_tree().create_timer(total_telegraph_time)
	_end_timer.timeout.connect(_on_telegraph_finished.bind(_current_telegraph_instance, telegraph_type), CONNECT_ONE_SHOT)


func _on_telegraph_finished(instance: Variant, telegraph_type: Type) -> void:
	# Ensure this signal handler doesn't get called multiple times on the same instance
	if _current_telegraph_instance != instance:
		return # This instance is not the currently managed one, ignore.

	_cleanup_telegraph() # Clean up the instance after it finishes

	if telegraph_type == Type.DEPARTURE:
		_current_state = State.FINDING_POSITION
		# Visibility handled by _on_telegraph_halfway. If it wasn't, ensure it's hidden now.
		if agent.visible: agent.visible = false
	elif telegraph_type == Type.ARRIVAL:
		_current_state = State.FINISHED # Action completes here


func _on_telegraph_halfway(telegraph_type: Type) -> void:
	# This signal handler for the halfway point
	if telegraph_type == Type.DEPARTURE:
		agent.visible = false
		agent.apply_gravity = false # Disable gravity after agent disappears
	elif telegraph_type == Type.ARRIVAL:
		agent.visible = true
		agent.global_position = _flank_position
		agent.velocity = Vector3.ZERO
		agent.apply_gravity = true # Re-enable gravity after teleport


func _cleanup_telegraph() -> void:
	if _current_telegraph_instance and is_instance_valid(_current_telegraph_instance):
		_current_telegraph_instance.queue_free()
	_current_telegraph_instance = null

	if _half_timer: 
		if _half_timer.timeout.is_connected(_on_telegraph_halfway):
			_half_timer.timeout.disconnect(_on_telegraph_halfway)
		_half_timer = null

	if _end_timer: 
		if _end_timer.timeout.is_connected(_on_telegraph_finished):
			_end_timer.timeout.disconnect(_on_telegraph_finished)
		_end_timer = null


func _log_error(message: String) -> void:
	push_error("Flank Action Error: %s" % message)


func _log_warning(message: String) -> void:
	push_warning("Flank Action Warning: %s" % message)
