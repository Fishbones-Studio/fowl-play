class_name MeleeWeaponNode extends Node3D
# Used to get reference to player/enemy in their respective scenes.
@export var actor : CharacterBody3D
@export var melee_weapon_scene : PackedScene # TODO: implement correct checking

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
		
	current_weapon = melee_weapon_scene.instantiate() as MeleeWeapon
	print("Instantiated weapon: " + current_weapon.name)
	
	add_child(current_weapon)
	melee_state_machine.setup(actor, current_weapon)
