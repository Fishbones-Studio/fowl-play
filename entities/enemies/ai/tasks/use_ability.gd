@tool
extends BTAction

## Ignore ability cooldown
@export var ignore_cooldown: bool = false
## Ability slot
@export_range(0, 2) var slot: int = 0
@export var force_activate: bool = false


func _generate_name() -> String:
	return "Use Ability ➜ slot %d, ignore_cooldown: %s" % [slot, ignore_cooldown]


func _tick(_delta: float) -> Status:
	var ability_slot: AbilitySlot = agent.enemy_ability_controller.abilities.keys()[slot]
	var condition: bool = agent.enemy_ability_controller.try_activate_ability(ability_slot, ignore_cooldown, force_activate)

	if not condition:
		return FAILURE

	return SUCCESS
