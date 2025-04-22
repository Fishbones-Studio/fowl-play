class_name EnemyAbilityController
extends Node3D

@export var enemy: Enemy

var abilities: Dictionary[EnemyAbilitySlot, Ability]


func _ready() -> void:
	assert(enemy, "No enmey reference set for: %s" % name) # For debugging

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

	if ability.current_ability.name == "Ground Pound":
		enemy.velocity.y += 50

	ability.activate()


func _on_attacking_area_body_entered(body: Node3D) -> void:
	_try_activate_ability(abilities.keys()[0])
	_try_activate_ability(abilities.keys()[1])
