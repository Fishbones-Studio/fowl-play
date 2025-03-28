class_name EntityStats
extends Resource

@export_category("Base Stats")
@export var max_health: float
@export var max_stamina: float
@export var attack: int
@export var defense: int
@export var speed: float
@export var weight: int

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
	current_health = max_health
	current_stamina = max_stamina


## Calculate the speed based on weight and speed factor
func calculate_speed(speed_factor: float) -> float:
	return speed * exp(-(weight) * weight_factor) * speed_factor


func restore_health(amount: float) -> float:
	current_health += amount
	return current_health


func restore_stamina(amount: float) -> float:
	current_stamina += amount
	return current_stamina


func drain_health(amount: float) -> float:
	current_health -= amount
	return current_health


func drain_stamina(amount: float) -> float:
	current_stamina -= amount
	return current_stamina


## Regenerate health over delta time
func regen_health(delta: float) -> float:
	current_health += health_regen * delta
	return current_health


## Regenerate stamina over delta time
func regen_stamina(delta: float) -> float:
	current_stamina += stamina_regen * delta
	return current_stamina
