class_name LivingEntityStats
extends Resource

@export_category("Base Stats")
@export var max_health: float = 100.0
@export var max_stamina: float = 100.0
@export var attack: float = 10.0
@export_range(0, 1000) var defense: int = 0
@export var speed: float = 5.0
@export var weight: float = 10.0

@export_category("Factors")
@export var health_regen: int = 1
@export var stamina_regen: int = 5
@export var weight_factor: float = 0.07 # Controls slowdown strength
@export var k_scaler : float = 100.0 # Controlls scaling for damage and defense

@export_group("Holder")
@export var is_player : bool = false

var current_health: float:
	set(value):
		# Clamp based on the *current* max_health
		current_health = clamp(value, 0, max_health)

var current_stamina: float:
	set(value):
		# Clamp based on the *current* max_stamina
		current_stamina = clamp(value, 0, max_stamina)

# Initialize stats, setting health and stamina to max
func init() -> void:
	if max_health <= 0: push_error("Max health must be positive.")
	if max_stamina <= 0: push_error("Max stamina must be positive.")
	if current_health == 0:
		current_health = max_health
	if current_stamina == 0:
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
	var actual_damage: float = 0.0
	if amount < -9000000:
		# check for cheat
		actual_damage = current_health
	elif amount <= 0:
		print("health drain amount is negative: " + str(amount))
		return 0.0 # Don't drain if amount is zero or negative
	else:
		if damage_type == DamageEnums.DamageTypes.NORMAL:
			var damage_multiplier: float = 100.0 / (k_scaler + float(defense))
			actual_damage = max(floor(amount * damage_multiplier), 1)

		elif damage_type == DamageEnums.DamageTypes.TRUE:
			actual_damage = amount

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

## Calculate the damage based on the attack and the k_scaler
func calc_scaled_damage(damage: float) -> float:
	var actual_damage: float
	if is_inf(attack):
		return INF
	elif attack < -k_scaler:
		# Avoid division by zero or negative denominator if attack is very negative
		printerr("Attack value is too low, results may be unexpected.")
		return floor(damage)
	else:
		var scale: float = 1.0 + (attack / (k_scaler + attack))
		actual_damage = floor(damage * scale)

	return actual_damage


## Calculate the defense based on the defense and the k_scaler
func apply_upgrade(upgrade: UpgradeResource) -> void:
	max_health += upgrade.health_bonus
	current_health += upgrade.health_bonus

	max_stamina += upgrade.stamina_bonus
	current_stamina += upgrade.stamina_bonus

	attack += upgrade.attack_bonus

	defense += upgrade.defense_bonus

	speed += upgrade.speed_bonus

	weight += upgrade.weight_bonus
	
	# Ensure current values are clamped after potential changes
	current_health = clamp(current_health, 0, max_health)
	current_stamina = clamp(current_stamina, 0, max_stamina)

## Convert the current state of this resource to a Dictionary for saving.
func to_dict() -> Dictionary:
	return {
	# Base Stats
		"max_health": max_health,
		"max_stamina": max_stamina,
		"attack": attack,
		"defense": defense,
		"speed": speed,
		"weight": weight,
	# Factors
		"health_regen": health_regen,
		"stamina_regen": stamina_regen,
		"weight_factor": weight_factor,
		"k_scaler": k_scaler,
	# Holder
		"is_player": is_player,
	}

## Create a new LivingEntityStats instance from a Dictionary.
static func from_dict(data: Dictionary) -> LivingEntityStats:
	var new_stats := LivingEntityStats.new()

	# Load Base Stats
	new_stats.max_health = data.get("max_health", 100.0)
	new_stats.max_stamina = data.get("max_stamina", 100.0)
	new_stats.attack = data.get("attack", 10.0)
	new_stats.defense = data.get("defense", 0)
	new_stats.speed = data.get("speed", 5.0)
	new_stats.weight = data.get("weight", 10.0)

	# Load Factors
	new_stats.health_regen = data.get("health_regen", 1)
	new_stats.stamina_regen = data.get("stamina_regen", 5)
	new_stats.weight_factor = data.get("weight_factor", 0.07)
	new_stats.k_scaler = data.get("k_scaler", 100.0)

	# Load Holder
	new_stats.is_player = data.get("is_player", false)
	
	return new_stats

