class_name ShaderPreloader
extends Node

signal preloading_started(total_scenes: int)
signal preloading_progress(current_scene: int, scene_path: String)
signal preloading_completed()
signal preloading_failed(error: String)

var _is_preloading: bool = false
var _preload_scene: Node3D # Node to temporarily host instanced scenes/meshes
var _processed_materials: Dictionary = {} # To track unique materials

func _ready() -> void:
	_preload_scene = Node3D.new()
	_preload_scene.name = "ShaderPreloadScene_Temporary" # Give it a unique name
	_preload_scene.visible = false # Keep it invisible
	add_child(_preload_scene)


func start_preloading() -> void:
	if _is_preloading:
		printerr("ShaderPreloader: Preloading already in progress.")
		return

	var scene_paths: Array[String] = SceneScanner.load_scene_config()
	if scene_paths.is_empty():
		var msg: String = "ShaderPreloader: No scenes found in config to preload."
		print(msg)
		emit_signal("preloading_failed", msg)
		return

	_is_preloading = true
	_processed_materials.clear()
	emit_signal("preloading_started", scene_paths.size())
	print("ShaderPreloader: Starting preloading of ", scene_paths.size(), " scenes.")
	
	call_deferred("_start_async_preloading", scene_paths)

func _start_async_preloading(scene_paths: Array[String]) -> void:
	await _preload_scenes_async(scene_paths)


func _preload_scenes_async(scene_paths: Array[String]) -> void:
	for i in range(scene_paths.size()):
		var scene_path: String = scene_paths[i]
		emit_signal("preloading_progress", i + 1, scene_path)
		print("ShaderPreloader: Preloading scene ", (i + 1), "/", scene_paths.size(), ": ", scene_path)

		ResourceLoader.load_threaded_request(scene_path)
		var resource_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.THREAD_LOAD_IN_PROGRESS
		
		while resource_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			resource_status = ResourceLoader.load_threaded_get_status(scene_path)
			await get_tree().process_frame

		if resource_status == ResourceLoader.THREAD_LOAD_LOADED:
			var packed_scene: PackedScene = ResourceLoader.load_threaded_get(scene_path)
			if packed_scene:
				await _process_scene_materials_for_preloading(packed_scene)
			else:
				printerr("ShaderPreloader: Failed to get PackedScene after loading: ", scene_path)
		else:
			printerr("ShaderPreloader: Failed to load scene (status: ", resource_status, "): ", scene_path)
		
		await get_tree().process_frame # Small delay

	_is_preloading = false
	print("ShaderPreloader: Preloading completed. Processed ", _processed_materials.size(), " unique materials.")
	emit_signal("preloading_completed")


func _disable_processing_recursive(node: Node) -> void:
	node.set_process_mode(Node.PROCESS_MODE_DISABLED)
	for child in node.get_children():
		_disable_processing_recursive(child)


func _process_scene_materials_for_preloading(packed_scene: PackedScene) -> void:
	# Instantiate with GEN_EDIT_STATE_DISABLED
	var instance: Node = packed_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	if not instance:
		printerr("ShaderPreloader: Failed to instantiate scene in disabled state: ", packed_scene.resource_path)
		return

	# Explicitly disable processing for all nodes in the instanced scene
	_disable_processing_recursive(instance)

	_preload_scene.add_child(instance) # Add to our temporary scene
	
	await _find_and_process_materials_in_node(instance)
	
	instance.queue_free() # Clean up the instanced scene
	await get_tree().process_frame # Allow a frame for cleanup


func _find_and_process_materials_in_node(node: Node) -> void:
	if node is MeshInstance3D:
		await _process_mesh_instance_materials(node as MeshInstance3D)
	elif node is GPUParticles3D:
		await _process_gpu_particle_materials(node as GPUParticles3D)
	elif node is CPUParticles3D:
		await _process_cpu_particle_materials(node as CPUParticles3D)
	
	# Process material override if present
	if node.has_method("get_material_override"):
		var material_override = node.get_material_override()
		if material_override:
			await _process_material_resource(material_override)
	
	for child in node.get_children():
		await _find_and_process_materials_in_node(child)


func _process_mesh_instance_materials(mesh_instance: MeshInstance3D) -> void:
	var surface_count: int = mesh_instance.get_surface_override_material_count()
	for i in range(surface_count):
		var material: Material = mesh_instance.get_surface_override_material(i)
		if material:
			await _process_material_resource(material)
	
	if mesh_instance.mesh:
		var mesh: Mesh = mesh_instance.mesh
		surface_count = mesh.get_surface_count()
		for i in range(surface_count):
			var material: Material = mesh.surface_get_material(i)
			if material:
				await _process_material_resource(material)


func _process_gpu_particle_materials(particles: GPUParticles3D) -> void:
	if particles.process_material: # This is a ShaderMaterial or ParticleProcessMaterial
		await _process_material_resource(particles.process_material)

	var draw_pass_meshes_to_check: Array[Mesh] = []
	if particles.draw_passes >= 1 and particles.draw_pass_1:
		draw_pass_meshes_to_check.append(particles.draw_pass_1)
	if particles.draw_passes >= 2 and particles.draw_pass_2:
		draw_pass_meshes_to_check.append(particles.draw_pass_2)
	if particles.draw_passes >= 3 and particles.draw_pass_3:
		draw_pass_meshes_to_check.append(particles.draw_pass_3)
	if particles.draw_passes >= 4 and particles.draw_pass_4:
		draw_pass_meshes_to_check.append(particles.draw_pass_4)

	for mesh_in_pass in draw_pass_meshes_to_check:
		if mesh_in_pass: # Check if mesh is assigned
			var surface_count: int = mesh_in_pass.get_surface_count()
			for surf_idx in range(surface_count):
				var material: Material = mesh_in_pass.surface_get_material(surf_idx)
				if material:
					await _process_material_resource(material)
	
	if particles.amount > 0:
		var original_emitting_state: bool = particles.emitting
		particles.emitting = true
		particles.restart()
		for _i in range(5): await get_tree().process_frame
		particles.emitting = original_emitting_state
		if not original_emitting_state: particles.restart()


func _process_cpu_particle_materials(particles: CPUParticles3D) -> void:
	if particles.material_override: # For CPUParticles3D, it's material_override
		await _process_material_resource(particles.material_override)
	elif particles.mesh and particles.mesh.get_surface_count() > 0:
		var mesh: Mesh = particles.mesh
		for i in range(mesh.get_surface_count()):
			var material: Material = mesh.surface_get_material(i)
			if material:
				await _process_material_resource(material)

	if particles.amount > 0:
		var original_emitting_state: bool = particles.emitting
		particles.emitting = true
		particles.restart()
		for _i in range(5): await get_tree().process_frame
		particles.emitting = original_emitting_state
		if not original_emitting_state: particles.restart()


func _process_material_resource(material: Material) -> void:
	if not material:
		return
	
	var material_id: int = material.get_instance_id()
	if material_id in _processed_materials:
		return # Already processed this specific material instance
	
	_processed_materials[material_id] = true
	
	# Create a minimal temporary mesh instance to trigger shader compilation
	var temp_mesh_res := BoxMesh.new()
	temp_mesh_res.size = Vector3(0.1, 0.1, 0.1)
	
	var temp_mesh_instance := MeshInstance3D.new()
	temp_mesh_instance.mesh = temp_mesh_res
	temp_mesh_instance.set_surface_override_material(0, material)
	
	_preload_scene.add_child(temp_mesh_instance)
	
	# Allow a few frames for the rendering server to see and compile
	for _i in range(4):
		await get_tree().process_frame
	
	temp_mesh_instance.queue_free() # Clean up the temporary mesh instance
	
	print("ShaderPreloader: Processed material: ", material.resource_path if material.resource_path else "built-in/unique")
