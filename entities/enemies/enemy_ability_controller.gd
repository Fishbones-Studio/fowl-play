class_name EnemyAbilityController
extends Node3D

@export var enemy: Enemy

var abilities: Dictionary[AbilitySlot, Ability]


func _ready() -> void:
	assert(enemy, "No enemy reference set for: %s" % name) # For debugging

	# Initialize all child AbilitySlots
	for child: AbilitySlot in get_children():
		child.setup(enemy)

		if not is_instance_valid(child.ability): continue
		abilities[child] = child.ability


func try_activate_ability(ability_slot: AbilitySlot = abilities.keys()[0], 
		ignore_cooldown: bool = false,
		force_activate: bool = false,
	) -> bool:
	var ability = abilities[ability_slot]

	if not ability:
		push_error("Ability not set for slot: ", ability_slot)
		return false

	if force_activate:
		ability.activate(force_activate)

	if ignore_cooldown:
		ability.cooldown_timer.stop()

	if ability.on_cooldown:
		print("Ability is on cooldown: ", ability.name)
		return false

	if not ability.has_method("activate"):
		push_error("Ability missing 'activate' method: ", ability.name)
		return false

	ability.activate()
	return true
