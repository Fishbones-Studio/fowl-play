@tool
extends BTAction

## The amount of health to decrease from the agent (IN PERCENTAGE).
@export_range(0.0, 100.0, 0.1) var amount: float = 0.0
## The type of damage (to ignore defense or not)
@export var damage_type: DamageEnums.DamageTypes = DamageEnums.DamageTypes.TRUE


func _generate_name() -> String:
	return "Hurt ➜ Agent for %.1f%%, %s Damage" % [amount, DamageEnums.damage_type_to_string(damage_type)]


func _enter() -> void:
	if amount > 0.0:
		agent.stats.drain_health(agent.stats.max_health * (amount / 100.0), damage_type)


func _tick(_delta: float) -> Status:
	return SUCCESS
