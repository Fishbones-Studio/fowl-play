class_name AbilitySlot
extends Node3D

@export var ability_resource: AbilityResource # Can be set for default player ability

var ability: Ability


func setup(holder: CharacterBody3D) -> void:
	if ability_resource == null:
		push_warning("No ability for slot set: ", name)
		queue_free()
		return
	
	if ability_resource.model_uid.is_empty():
		push_error("AbilityResource has empty model_uid: ", ability_resource.resource_path)
		return
	
	var ability_scene = load(ability_resource.model_uid)
	if ability_scene == null:
		push_error("Failed to load ability scene: ", ability_resource.model_uid)
		return
	
	var instance = ability_scene.instantiate()
	if not instance is Ability:
		push_error("Instantiated object is not an Ability: ", ability_resource.model_uid)
		instance.queue_free()
		return
	
	add_child(instance)
	ability = instance
	
	if holder: ability.ability_holder = holder
