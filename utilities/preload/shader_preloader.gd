class_name ShaderPreloader
extends Node

signal preloading_started(total_scenes: int)
signal preloading_progress(current_scene: int, scene_path: String)
signal preloading_completed()
signal preloading_failed(error: String)

var _is_preloading: bool = false
var _preload_scene: Node3D # Node to temporarily host instanced scenes/meshes
var _processed_materials: Dictionary = {} # To track unique materials globally

const FRAMES_FOR_MATERIAL_BATCH_PROCESSING: int = 4
const FRAMES_FOR_PARTICLE_PROCESSING: int = 5

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
				await _process_scene_resources_for_preloading(packed_scene)
			else:
				printerr("ShaderPreloader: Failed to get PackedScene after loading: ", scene_path)
		else:
			printerr("ShaderPreloader: Failed to load scene (status: ", resource_status, "): ", scene_path)

		await get_tree().process_frame # Small delay between scenes

	_is_preloading = false
	print("ShaderPreloader: Preloading completed. Processed ", _processed_materials.size(), " unique materials.")
	emit_signal("preloading_completed")


func _disable_processing_recursive(node: Node) -> void:
	node.set_process_mode(Node.PROCESS_MODE_DISABLED)
	for child in node.get_children():
		_disable_processing_recursive(child)


func _process_scene_resources_for_preloading(packed_scene: PackedScene) -> void:
	var instance: Node = packed_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	if not instance:
		printerr("ShaderPreloader: Failed to instantiate scene: ", packed_scene.resource_path)
		return

	# Explicitly disable processing for all nodes in the instanced scene
	_disable_processing_recursive(instance)
	_preload_scene.add_child(instance) # Add main instance to our temp scene

	# Collect all unique, new materials from the instantiated scene
	var materials_to_batch_process: Array[Material] = []
	_recursive_collect_materials(instance, materials_to_batch_process)

	# Batch process collected materials by creating temporary meshes
	if not materials_to_batch_process.is_empty():
		var temp_mesh_instances_batch: Array[MeshInstance3D] = []
		var temp_mesh_res: BoxMesh = BoxMesh.new() # Create one mesh resource to reuse
		temp_mesh_res.size = Vector3(0.01, 0.01, 0.01) # Make it very small

		for material_to_process in materials_to_batch_process:
			var temp_mesh_instance: MeshInstance3D = MeshInstance3D.new()
			temp_mesh_instance.mesh = temp_mesh_res
			temp_mesh_instance.set_surface_override_material(0, material_to_process)
			
			_preload_scene.add_child(temp_mesh_instance) # Add temp mesh to the same scene as the main instance
			temp_mesh_instances_batch.append(temp_mesh_instance)
			
			_processed_materials[material_to_process.get_instance_id()] = true # Mark as globally processed
			#print("ShaderPreloader: Queued material for batch: ", material_to_process.resource_path if material_to_process.resource_path else "built-in/unique")

		print("ShaderPreloader: Processing batch of ", temp_mesh_instances_batch.size(), " materials for scene: ", packed_scene.resource_path)
		for _i in range(FRAMES_FOR_MATERIAL_BATCH_PROCESSING):
			await get_tree().process_frame
		
		for temp_mi in temp_mesh_instances_batch:
			temp_mi.queue_free()
		
		if not temp_mesh_instances_batch.is_empty():
			await get_tree().process_frame # Allow a frame for temp meshes cleanup


	# Process particle systems
	await _process_particle_systems_in_node_recursive(instance)

	# Clean up the main instanced scene
	instance.queue_free()
	await get_tree().process_frame # Allow a frame for main instance cleanup


func _recursive_collect_materials(node: Node, collected_materials_list: Array[Material]) -> void:
	if node is MeshInstance3D:
		var mi: MeshInstance3D = node
		for i in range(mi.get_surface_override_material_count()):
			var mat: Material = mi.get_surface_override_material(i)
			if mat and not (mat.get_instance_id() in _processed_materials) and not collected_materials_list.has(mat):
				collected_materials_list.append(mat)
		if mi.mesh:
			for i in range(mi.mesh.get_surface_count()):
				var mat: Material = mi.mesh.surface_get_material(i)
				if mat and not (mat.get_instance_id() in _processed_materials) and not collected_materials_list.has(mat):
					collected_materials_list.append(mat)

	elif node is GPUParticles3D:
		var gpu_particles: GPUParticles3D = node
		if gpu_particles.process_material:
			var mat: Material = gpu_particles.process_material
			if mat and not (mat.get_instance_id() in _processed_materials) and not collected_materials_list.has(mat):
				collected_materials_list.append(mat)
		
		var draw_pass_meshes: Array[Mesh] = []
		if gpu_particles.draw_passes >= 1 and gpu_particles.draw_pass_1: draw_pass_meshes.append(gpu_particles.draw_pass_1)
		if gpu_particles.draw_passes >= 2 and gpu_particles.draw_pass_2: draw_pass_meshes.append(gpu_particles.draw_pass_2)
		if gpu_particles.draw_passes >= 3 and gpu_particles.draw_pass_3: draw_pass_meshes.append(gpu_particles.draw_pass_3)
		if gpu_particles.draw_passes >= 4 and gpu_particles.draw_pass_4: draw_pass_meshes.append(gpu_particles.draw_pass_4)
		
		for mesh_in_pass in draw_pass_meshes:
			if mesh_in_pass:
				for i in range(mesh_in_pass.get_surface_count()):
					var mat_surf: Material = mesh_in_pass.surface_get_material(i)
					if mat_surf and not (mat_surf.get_instance_id() in _processed_materials) and not collected_materials_list.has(mat_surf):
						collected_materials_list.append(mat_surf)

	elif node is CPUParticles3D:
		var cpu_particles: CPUParticles3D = node
		var material_to_check: Material = cpu_particles.material_override
		if material_to_check and not (material_to_check.get_instance_id() in _processed_materials) and not collected_materials_list.has(material_to_check):
			collected_materials_list.append(material_to_check)
		
		if cpu_particles.mesh: # Also check mesh materials if no override or if override is different
			for i in range(cpu_particles.mesh.get_surface_count()):
				var mat_surf: Material = cpu_particles.mesh.surface_get_material(i)
				if mat_surf and not (mat_surf.get_instance_id() in _processed_materials) and not collected_materials_list.has(mat_surf):
					collected_materials_list.append(mat_surf)

	if node.has_method("get_material_override"): # General material override
		var mat_override = node.get_material_override()
		if mat_override and not (mat_override.get_instance_id() in _processed_materials) and not collected_materials_list.has(mat_override):
			collected_materials_list.append(mat_override)

	for child in node.get_children():
		_recursive_collect_materials(child, collected_materials_list)


func _process_particle_systems_in_node_recursive(node: Node) -> void:
	if node is GPUParticles3D or node is CPUParticles3D:
		var particles: Node = node
		if particles.amount > 0:
			var original_emitting_state: bool = particles.emitting
			particles.emitting = true
			particles.restart()
			for _i in range(FRAMES_FOR_PARTICLE_PROCESSING):
				await get_tree().process_frame
			particles.emitting = original_emitting_state
			if not original_emitting_state:
				particles.restart() # Ensure particles are cleared if they weren't meant to be emitting

	for child in node.get_children():
		await _process_particle_systems_in_node_recursive(child)
