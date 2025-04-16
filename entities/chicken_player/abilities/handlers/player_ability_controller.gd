################################################################################
## Manages the player's abilities, handling activation, cooldowns, and input.
##
## This controller links AbilitySlot nodes to the player character and processes 
## input to trigger abilities when conditions are met (cooldowns, resources, etc.).
## Add AbilitySlot children to this node to register them with the controller.
################################################################################
class_name PlayerAbilityController
extends Node3D

@export var player: ChickenPlayer

var abilities: Dictionary[AbilitySlot, Ability]


func _ready() -> void:
	assert(player, "No player reference set for: %s" % name) # For debugging

	# Initialize all child AbilitySlots
	for child: AbilitySlot in get_children():
		child.setup(player)

		if not is_instance_valid(child.ability): continue
		abilities[child] = child.ability


func _input(_event: InputEvent) -> void:
	if abilities.size() > 0 and Input.is_action_just_pressed("ability_one"):
		_try_activate_ability(abilities.keys()[0])
	if abilities.size() > 1 and Input.is_action_just_pressed("ability_two"):
		_try_activate_ability(abilities.keys()[1])


func _try_activate_ability(ability_slot: AbilitySlot) -> void:
	var ability = abilities[ability_slot]

	if not ability:
		push_error("Ability not set for slot: ", ability_slot)
		return

	if ability.on_cooldown:
		print("Ability is on cooldown: ", ability.name)
		return

	if not ability.has_method("activate"):
		push_error("Ability missing 'activate' method: ", ability.name)
		return

	ability.activate()
