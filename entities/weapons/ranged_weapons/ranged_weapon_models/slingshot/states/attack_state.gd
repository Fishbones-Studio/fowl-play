extends BaseRangedCombatState

# Number of points in the trajectory line
const MAX_TRAJECTORY_POINTS: int = 50
# Time step between trajectory points
const TRAJECTORY_TIME_STEP: float = 0.05

@export var projectile_scene: PackedScene = preload("uid://d1jf4shjaqq4n")
@export var attack_origin: Node3D
@export var launch_speed: float = 20.0
@export var launch_angle_degrees: float = 30.0
@export var trajectory_line_color: Color = Color(1.0, 1.0, 0.0, 0.21568628)
@export var trajectory_line_width: float = 0.2 # Width of the trajectory visualization

# Trajectory Preview Variables
var _trajectory_preview_mesh_instance: MeshInstance3D
var _trajectory_preview_mesh: ArrayMesh

func _init():
	state_type = WeaponEnums.WeaponState.ATTACKING

func _ready() -> void:
	# Initialize the trajectory preview objects once
	_trajectory_preview_mesh = ArrayMesh.new()
	_trajectory_preview_mesh_instance = MeshInstance3D.new()
	_trajectory_preview_mesh_instance.mesh = _trajectory_preview_mesh
	_trajectory_preview_mesh_instance.name = "SlingshotTrajectoryPreview"

	var material = StandardMaterial3D.new()
	material.albedo_color = trajectory_line_color
	material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	material.flags_transparent = trajectory_line_color.a < 1.0
	_trajectory_preview_mesh_instance.material_override = material


func enter(_previous_state, _info: Dictionary = {}) -> void:
	if not weapon or not weapon.current_weapon or not weapon.entity_stats:
		push_error("SlingshotAttackState: Weapon, current_weapon, or entity_stats not properly set up!")
		if transition_signal:
			transition_signal.emit(WeaponEnums.WeaponState.IDLE, {})
		set_physics_process(false)
		return

	if weapon.entity_stats.is_player:
		SignalManager.cooldown_item_slot.emit(
			weapon.current_weapon,
			weapon.current_weapon.windup_time,
			false
		)

	# Add trajectory preview to the scene
	if _trajectory_preview_mesh_instance and not _trajectory_preview_mesh_instance.is_inside_tree():
		get_tree().current_scene.add_child(_trajectory_preview_mesh_instance)
	_trajectory_preview_mesh_instance.global_transform = Transform3D.IDENTITY
	_trajectory_preview_mesh_instance.visible = true

	set_physics_process(true)
	_update_trajectory_preview()


func exit() -> void:
	set_physics_process(false)
	_fire_projectile()

	# Remove preview
	if _trajectory_preview_mesh_instance and _trajectory_preview_mesh_instance.is_inside_tree():
		_trajectory_preview_mesh_instance.get_parent().remove_child(_trajectory_preview_mesh_instance)


func _physics_process(_delta: float) -> void:
	if _trajectory_preview_mesh_instance and _trajectory_preview_mesh_instance.visible:
		if attack_origin and attack_origin.is_inside_tree():
			_update_trajectory_preview()
		else:
			# Hide preview if attack_origin becomes invalid
			_trajectory_preview_mesh_instance.visible = false
			_trajectory_preview_mesh.clear_surfaces()


func _update_trajectory_preview() -> void:
	if not attack_origin or not is_instance_valid(_trajectory_preview_mesh_instance):
		if is_instance_valid(_trajectory_preview_mesh_instance):
			_trajectory_preview_mesh_instance.visible = false
			_trajectory_preview_mesh.clear_surfaces()
		return

	var points: PackedVector3Array = []
	var initial_pos: Vector3 = attack_origin.global_position
	var forward_dir: Vector3 = -attack_origin.global_transform.basis.z
	var right_dir: Vector3 = attack_origin.global_transform.basis.x
	var launch_angle_rad: float = deg_to_rad(launch_angle_degrees)
	var launch_direction: Vector3 = forward_dir.rotated(right_dir, launch_angle_rad).normalized()
	var initial_velocity: Vector3 = launch_direction * launch_speed

	var gravity_value: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	var gravity_vec: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * gravity_value

	for i in range(MAX_TRAJECTORY_POINTS):
		var t: float = float(i) * TRAJECTORY_TIME_STEP
		# Projectile motion equation: p(t) = p0 + v0*t + 0.5*g*t^2
		var current_point: Vector3 = initial_pos + initial_velocity * t + 0.5 * gravity_vec * t * t
		points.append(current_point)
		if i > 5 and current_point.y < initial_pos.y - 30.0:
			break

	_trajectory_preview_mesh.clear_surfaces()
	if points.size() < 2:
		_trajectory_preview_mesh_instance.visible = false
		return

	# Generate a wide strip along the trajectory
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	var color: Color = trajectory_line_color

	for i in range(points.size()):
		var p: Vector3 = points[i]
		var tangent: Vector3
		if i < points.size() - 1:
			tangent = (points[i + 1] - p).normalized()
		else:
			tangent = (p - points[i - 1]).normalized()
		var up: Vector3 = Vector3.UP
		var normal: Vector3 = tangent.cross(up).normalized()
		if normal.length() < 0.01:
			normal = Vector3.RIGHT
		var offset: Vector3 = normal * (trajectory_line_width * 0.5)
		st.set_color(color)
		st.add_vertex(p + offset)
		st.set_color(color)
		st.add_vertex(p - offset)

	#  use commit_to_arrays and add_surface_from_arrays
	var arrays = st.commit_to_arrays()
	_trajectory_preview_mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLE_STRIP,
		arrays
	)
	_trajectory_preview_mesh_instance.visible = true


func _fire_projectile() -> void:
	if not projectile_scene:
		push_error("SlingshotAttackState: Projectile scene not set!")
		return
	if not attack_origin:
		push_error("SlingshotAttackState: Attack origin not set!")
		return

	var projectile_instance: Node = projectile_scene.instantiate()
	if not projectile_instance is RigidBody3D:
		push_error("SlingshotAttackState: Projectile scene root must be a RigidBody3D.")
		projectile_instance.queue_free()
		return

	get_tree().current_scene.add_child(projectile_instance)
	projectile_instance.global_position = attack_origin.global_position
	projectile_instance.global_rotation = attack_origin.global_rotation

	var forward_dir: Vector3 = -attack_origin.global_transform.basis.z
	var right_dir: Vector3 = attack_origin.global_transform.basis.x
	var launch_angle_rad: float = deg_to_rad(launch_angle_degrees)
	var launch_direction: Vector3 = forward_dir.rotated(right_dir, launch_angle_rad).normalized()

	projectile_instance.linear_velocity = launch_direction * launch_speed
	projectile_instance.angular_velocity = Vector3(
		randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)
	).normalized() * PI

	if projectile_instance.has_method("setup_projectile"):
		projectile_instance.setup_projectile(
			weapon.entity_stats, weapon.current_weapon.damage
		)
	else:
		push_error("Provided projectile cannot be set up")
