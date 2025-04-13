@tool
class_name MeleeWeaponNode extends Node3D

# Used to get reference to player/enemy in their respective scenes.
@export var actor : CharacterBody3D
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

var current_weapon: MeleeWeapon

@onready var melee_state_machine : MeleeStateMachine = $MeleeStateMachine

func _ready():
	# In enemy, the export vars are set, so we can immediatly run the setup
	if actor && melee_weapon_scene:
		setup()

func setup():
	if not melee_weapon_scene:
		push_error("No valid weapon scene assigned!")
		return
	if not current_weapon:
		current_weapon = melee_weapon_scene.instantiate() as MeleeWeapon
		print("Instantiated melee weapon: " + current_weapon.name)
	
	add_child(current_weapon)
	melee_state_machine.setup(actor, current_weapon)
