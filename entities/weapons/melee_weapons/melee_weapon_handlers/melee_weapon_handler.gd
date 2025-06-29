class_name MeleeWeaponNode 
extends Node3D

@export_group("Weapon")
@export var melee_weapon_scene: PackedScene:
	set(value):
		if value == null:
			melee_weapon_scene = null
			current_weapon = null
			return
		# Custom setter to validate the scene type
		var temp_weapon_instance: Node3D = value.instantiate()
		if value and value.can_instantiate() and temp_weapon_instance is MeleeWeapon:
			melee_weapon_scene = value
			current_weapon = temp_weapon_instance
		else:
			push_error("Assigned scene is not a valid Weapon type")
			melee_weapon_scene = null

# Using flags for user-friendly layer selection in the editor
@export_flags_3d_physics var weapon_collision_mask: int:
	set(value):
		weapon_collision_mask = value
		if current_weapon:
			current_weapon.hit_mask = weapon_collision_mask
		

var current_weapon: MeleeWeapon
var owner_stats: LivingEntityStats

@onready var melee_state_machine: MeleeWeaponStateMachine = $MeleeStateMachine


func _ready() -> void:
	# In enemy, the export vars are set, so we can immediatly run the setup
	if melee_weapon_scene:
		setup()


func setup() -> void:
	if !owner_stats:
		# If owner_stats is not set, we need to search for it in the parent chain
		var current_node: Node = get_parent()
		while current_node != null:
			# Check if the node has the getter function
			if current_node.has_method("get_stats_resource"):
				var potential_stats: LivingEntityStats = current_node.get_stats_resource()
				if potential_stats is LivingEntityStats:
					owner_stats = potential_stats
					print(
						"MeleeWeaponNode found stats on: ",
						current_node.name
					)
					break # Stop searching once found
	
			# Move up to the next parent
			current_node = current_node.get_parent()

	if owner_stats == null:
		push_error(
			"MeleeWeaponNode could not find a parent with get_stats_resource() "
			+ "returning LivingEntityStats! Weapon might not function correctly."
		)

	if owner_stats.is_player:
		GameManager.player_stats_updated.connect(
			func (new_stats: LivingEntityStats):
				owner_stats = new_stats
				melee_state_machine.update_entity_stats(owner_stats)
				print("MeleeWeaponNode updated stats to: ", owner_stats)
		)

	if not melee_weapon_scene:
		push_warning("No valid weapon scene assigned!")
		queue_free()
		return

	if not current_weapon:
		current_weapon = melee_weapon_scene.instantiate() as MeleeWeapon

	current_weapon.entity_stats = owner_stats
	print(owner_stats.to_dict())

	add_child(current_weapon)

	# set the defined collison mask
	current_weapon.hit_mask = weapon_collision_mask

	melee_state_machine.setup(current_weapon, owner_stats)
