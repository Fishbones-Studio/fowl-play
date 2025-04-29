class_name EnemyAbilityController
extends Node3D

@export var enemy: Enemy

var abilities: Dictionary[EnemyAbilitySlot, Ability]


func _ready() -> void:
	assert(enemy, "No enemy reference set for: %s" % name) # For debugging

	# Initialize all child AbilitySlots
	for child: EnemyAbilitySlot in get_children():
		child.setup(enemy)

		if not is_instance_valid(child.ability): continue
		abilities[child] = child.ability


func _try_activate_ability(ability_slot: EnemyAbilitySlot) -> void:
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


func _activate_first_ability() -> void:
	_try_activate_ability(abilities.keys()[0])


func _activate_second_ability() -> void:
	_try_activate_ability(abilities.keys()[1])
