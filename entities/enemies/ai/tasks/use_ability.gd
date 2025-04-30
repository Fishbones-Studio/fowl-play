@tool
extends BTAction

## Blackboard variable that stores our target.
@export var target_var: StringName = &"target"
## Ability slot
@export_range(0, 1) var slot: int = 0


func _generate_name() -> String:
	return "Use ability ➜ slot %d" % slot


func _tick(delta: float) -> Status:
	var ability_slot: AbilitySlot = agent.enemy_ability_controller.abilities.keys()[slot]
	agent.enemy_ability_controller.try_activate_ability(ability_slot)

	return SUCCESS
