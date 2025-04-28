class_name LivingEntityStats
extends Resource

@export_category("Base Stats")
@export var max_health: float
@export var max_stamina: float
@export var attack: float
@export_range(0, 1000) var defense: int = 0
@export var speed: float
@export var weight: float

@export_category("Factors")
@export var health_regen: int
@export var stamina_regen: int
@export var weight_factor: float = 0.07 # Controls slowdown strength

var current_health: float:
	set(value):
		current_health = clamp(value, 0, max_health)

var current_stamina: float:
	set(value):
		current_stamina = clamp(value, 0, max_stamina)


func init() -> void:
	if max_health <= 0: push_error("Forgot to set max_health")
	if max_stamina <= 0: push_error("Forgot to set max_stamina")
	current_health = max_health
	current_stamina = max_stamina


## Calculate the speed based on weight and speed factor
func calculate_speed(speed_factor: float) -> float:
	return max(speed * exp(-(weight) * weight_factor) * speed_factor, 0.1)


func restore_health(amount: float) -> float:
	current_health = clamp(current_health + amount, 0, max_health)
	return current_health


func restore_stamina(amount: float) -> float:
	current_stamina = clamp(current_stamina + amount, 0, max_stamina)
	return current_stamina


## Reduces health by the given amount, taking defense into account.
func drain_health(amount: float, damage_type: DamageEnums.DamageTypes = DamageEnums.DamageTypes.NORMAL) -> float:
	if amount <= 0: # Don't process non-positive damage amounts
		return current_health

	var actual_damage: float = 0.0

	if damage_type == DamageEnums.DamageTypes.NORMAL:
		# Calculate damage multiplier based on defense
		# defense = 50  -> multiplier = 0.66 (66% damage)
		var damage_multiplier: float = 100.0 / (100.0 + float(defense))
		# Always do at least 1 damage
		actual_damage = max(floor(amount * damage_multiplier), 1)

	elif damage_type == DamageEnums.DamageTypes.TRUE:
		# Ignores defense and apply the damage directly
		actual_damage = amount
	
	print("Damage: %s, Type: %s, Actual Damage: %s, Defense: %s" % [amount, damage_type, actual_damage, defense])

	current_health = clamp(current_health - actual_damage, 0, max_health)
	return actual_damage


func drain_stamina(amount: float) -> float:
	current_stamina = clamp(current_stamina - amount, 0, max_stamina)
	return current_stamina


## Regenerate health over delta time
func regen_health(delta: float) -> float:
	current_health = clamp(current_health + (current_health * delta), 0, max_health)
	return current_health


## Regenerate stamina over delta time
func regen_stamina(delta: float) -> float:
	current_stamina = clamp(current_stamina + (stamina_regen * delta), 0, max_stamina)
	return current_stamina


func apply_upgrade(upgrade: UpgradeResource) -> void:
	max_health += upgrade.health_bonus
	current_health += upgrade.health_bonus

	max_stamina += upgrade.stamina_bonus
	current_stamina += upgrade.stamina_bonus

	attack += upgrade.attack_bonus

	defense += upgrade.defense_bonus

	speed += upgrade.speed_bonus

	weight += upgrade.weight_bonus
