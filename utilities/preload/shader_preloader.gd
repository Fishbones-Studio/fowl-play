class_name ShaderPreloader
extends Node

signal preloading_started(total_scenes: int)
signal preloading_progress(current_scene: int, scene_path: String)
signal preloading_completed()
signal preloading_failed(error: String)

var _is_preloading: bool = false
var _preload_scene: Node3D
var _processed_materials: Dictionary = {}

func _ready() -> void:
	# Create a dedicated node for preloading materials
	_preload_scene = Node3D.new()
	_preload_scene.name = "ShaderPreloadScene"
	add_child(_preload_scene)
	_preload_scene.visible = false

func start_preloading() -> void:
	if _is_preloading:
		print("Preloading already in progress")
		return
	
	var scene_paths: Array[String] = SceneScanner.load_scene_config()
	if scene_paths.is_empty():
		emit_signal("preloading_failed", "No scenes found in config")
		return
	
	_is_preloading = true
	_processed_materials.clear()
	emit_signal("preloading_started", scene_paths.size())
	
	await _preload_scenes_async(scene_paths)

func _preload_scenes_async(scene_paths: Array[String]) -> void:
	for i in range(scene_paths.size()):
		var scene_path: String = scene_paths[i]
		
		emit_signal("preloading_progress", i + 1, scene_path)
		
		# Load scene asynchronously
		ResourceLoader.load_threaded_request(scene_path)
		
		# Wait for the scene to load
		var resource_status : ResourceLoader.ThreadLoadStatus = ResourceLoader.THREAD_LOAD_IN_PROGRESS
		while resource_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
			resource_status = ResourceLoader.load_threaded_get_status(scene_path)
		
		if resource_status == ResourceLoader.THREAD_LOAD_LOADED:
			var packed_scene: PackedScene = ResourceLoader.load_threaded_get(scene_path)
			if packed_scene:
				await _process_scene_materials(packed_scene)
		else:
			print("Failed to load scene: ", scene_path)
		
		# Small delay to prevent frame drops
		await get_tree().process_frame
	
	_is_preloading = false
	emit_signal("preloading_completed")
	print("Shader preloading completed. Processed ", _processed_materials.size(), " unique materials")

func _process_scene_materials(packed_scene: PackedScene) -> void:
	var instance: Node = packed_scene.instantiate()
	if not instance:
		return
	
	# Add to our preload scene temporarily
	_preload_scene.add_child(instance)
	
	# Process all materials in this scene
	await _find_and_process_materials(instance)
	
	# Clean up
	instance.queue_free()
	
	# Wait a frame for cleanup
	await get_tree().process_frame

func _find_and_process_materials(node: Node) -> void:
	# Process MeshInstance3D nodes
	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		await _process_mesh_instance_materials(mesh_instance)
	
	# Process GPUParticles3D
	elif node is GPUParticles3D:
		var particles: GPUParticles3D = node as GPUParticles3D
		await _process_particle_materials(particles)
	
	# Process other nodes that might have materials
	elif node.has_method("get_material_override") and node.get_material_override():
		await _process_material(node.get_material_override())
	
	# Recursively process children
	for child in node.get_children():
		await _find_and_process_materials(child)

func _process_mesh_instance_materials(mesh_instance: MeshInstance3D) -> void:
	# Process surface override materials
	var surface_count: int = mesh_instance.get_surface_override_material_count()
	for i in range(surface_count):
		var material: Material = mesh_instance.get_surface_override_material(i)
		if material:
			await _process_material(material)
	
	# Process mesh materials
	if mesh_instance.mesh:
		var mesh: Mesh = mesh_instance.mesh
		for i in range(mesh.get_surface_count()):
			var material: Material = mesh.surface_get_material(i)
			if material:
				await _process_material(material)

func _process_particle_materials(particles: GPUParticles3D) -> void:
	if particles.process_material:
		await _process_material(particles.process_material)
	
	if particles.draw_pass_1 and particles.draw_pass_1.surface_get_material_count() > 0:
		for i in range(particles.draw_pass_1.surface_get_material_count()):
			var material: Material = particles.draw_pass_1.surface_get_material(i)
			if material:
				await _process_material(material)

func _process_material(material: Material) -> void:
	if not material:
		return
	
	var material_id: int = material.get_instance_id()
	
	# Skip if we've already processed this material
	if material_id in _processed_materials:
		return
	
	_processed_materials[material_id] = true
	
	# Force shader compilation by creating a temporary mesh instance
	var temp_mesh = SphereMesh.new()
	temp_mesh.radius = 0.01
	temp_mesh.height = 0.01
	
	var temp_instance = MeshInstance3D.new()
	temp_instance.mesh = temp_mesh
	temp_instance.set_surface_override_material(0, material)
	
	_preload_scene.add_child(temp_instance)
	
	# Wait a few frames to ensure rendering pipeline processes the material
	for i in range(3):
		await get_tree().process_frame
	
	temp_instance.queue_free()
	
	print("Processed material: ", material.resource_path if material.resource_path else "built-in")
