@tool
class_name MeleeWeaponNode 
extends Node3D

# Used to get reference to player/enemy in their respective scenes.
@export_group("weapon")
@export var melee_weapon_scene: PackedScene:
	set(value):
		# Custom setter to validate the scene type
		var temp_weapon_instance = value.instantiate()
		if value and value.can_instantiate() and temp_weapon_instance is MeleeWeapon:
			melee_weapon_scene = value
			current_weapon = temp_weapon_instance
		else:
			push_error("Assigned scene is not a valid Weapon type")
			melee_weapon_scene = null
			
# Using flags for user-friendly layer selection in the editor
@export_flags_3d_physics var weapon_collision_mask: int

var current_weapon: MeleeWeapon

@onready var melee_state_machine : MeleeStateMachine = $MeleeStateMachine


func _ready() -> void:
	# In enemy, the export vars are set, so we can immediatly run the setup
	if melee_weapon_scene:
		setup()
	else:
		push_warning("No valid weapon scene assigned!")
		queue_free()


func setup() -> void:
	if not melee_weapon_scene:
		push_warning("No valid weapon scene assigned!")
		queue_free()
		return

	if not current_weapon:
		current_weapon = melee_weapon_scene.instantiate() as MeleeWeapon

	add_child(current_weapon)

	# set the defined collison mask
	current_weapon.hit_area.collision_mask = weapon_collision_mask

	melee_state_machine.setup(current_weapon)
