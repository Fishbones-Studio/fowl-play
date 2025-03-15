extends Node3D

var current_weapon_instance: Node3D
@export var current_weapon: WeaponResource

var current_state: BaseState

## Dictionary to map WeaponState enum values to state instances.
var states: Dictionary = {}

@onready var hitbox: Area3D = $"../HitArea"

func _ready():
	if not current_weapon:
		push_error("No weapon assigned!")
		return

	# Initialize states becouse we cant set states as child nodes of our statemachine
	states = {
		WeaponEnums.WeaponState.IDLE: IdleState.new(),
		WeaponEnums.WeaponState.WINDUP: WindupState.new(),
		WeaponEnums.WeaponState.ATTACKING: AttackingState.new(),
		WeaponEnums.WeaponState.COOLDOWN: CooldownState.new()
	}

	# Set the owner of each state to this state machine
	for state in states.values():
		state.weapon_state_machine = self

	# Equip the weapon and start in the Idle state
	equip_weapon(current_weapon)
	transition_to(WeaponEnums.WeaponState.IDLE)

func _process(delta: float):
	if current_state:
		current_state.process(delta)

## Transition to a new state using the WeaponState enum.
func transition_to(new_state: WeaponEnums.WeaponState):
	if current_state:
		current_state.exit()

	current_state = states.get(new_state)
	if current_state:
		current_state.enter()

## Equip a weapon.
func equip_weapon(weapon_resource: WeaponResource):
	if current_weapon_instance:
		current_weapon_instance.queue_free()

	current_weapon = weapon_resource

	if weapon_resource.model:
		current_weapon_instance = weapon_resource.model.instantiate()
		add_child(current_weapon_instance)
	elif weapon_resource:
		current_weapon_instance = weapon_resource.instantiate()
		add_child(current_weapon_instance)

	transition_to(WeaponEnums.WeaponState.IDLE)


func attack():
	var enemies = hitbox.get_overlapping_bodies()
	# we search for an class named enemy within our hitbox
	for enemy in enemies:
		if enemy is Enemy: 
			enemy.take_damage(current_weapon.damage)
