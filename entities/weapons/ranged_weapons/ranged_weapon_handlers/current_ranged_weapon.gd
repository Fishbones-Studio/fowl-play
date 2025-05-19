## Weapon State Machine: Manages weapon state transitions and behavior.
class_name RangedWeaponNode
extends Node3D

## Exported Variables
@export_group("Weapon")
@export var ranged_weapon_scene: PackedScene:
	set(value):
		if value == null:
			ranged_weapon_scene = null
			current_weapon = null
			return
		# Custom setter to validate the scene type
		var temp_weapon_instance = value.instantiate()
		if value and value.can_instantiate() and temp_weapon_instance is RangedWeapon:
			current_weapon = temp_weapon_instance
			ranged_weapon_scene = value
		else:
			push_error("Assigned scene is not a valid Weapon type")
			ranged_weapon_scene = null

var current_weapon: RangedWeapon
var owner_stats: LivingEntityStats


func _ready() -> void:
	if ranged_weapon_scene:
		setup()


func setup() -> void:
	if !owner_stats:
		var current_node: Node = get_parent()
		while current_node != null:
			# Check if the node has the getter function
			if current_node.has_method("get_stats_resource"):
				var potential_stats = current_node.get_stats_resource()
				if potential_stats is LivingEntityStats:
					owner_stats = potential_stats
					print(
						"RangedWeaponNode found stats on: ",
						current_node.name
					)
					break # Stop searching once found
	
			# Move up to the next parent
			current_node = current_node.get_parent()

	if owner_stats == null:
		push_error(
			"RangedWeaponNode could not find a parent with get_stats_resource() "
			+ "returning LivingEntityStats! Weapon might not function correctly."
		)

	if not ranged_weapon_scene:
		push_warning("No valid weapon scene assigned!")
		return

	if not current_weapon:
		current_weapon = ranged_weapon_scene.instantiate() as RangedWeapon

	if not current_weapon:
		push_error("Failed to instantiate ranged weapon!")
		return

	current_weapon.entity_stats = owner_stats

	add_child(current_weapon)
