@tool
extends BTAction

## The total amount of damage in percentage the agent must take for this action to succeed.
@export var damage_threshold_in_percentage: float = 10.0
## The maximum time (in seconds) within which the damage must be taken.
@export var time_span: float = 5.0

## Internal variable to store the agent's health from the previous tick, used to calculate damage taken per tick.
var _last_health: float = 0.0
## Internal variable to accumulate the total damage taken since the action entered.
var _damage_taken_since_start: float = 0.0
## Flag to indicate if the action has been successfully initialized in _enter().
var _is_initialized: bool = false 
## Internal variable to hold the true damage threshold (not in percentage).
var _threshold: float = 0.0


# Called in the editor to generate a customized name for the action node.
func _generate_name() -> String:
	var name_parts: Array[String] = ["DamageTaken"]
	name_parts.append("Threshold: %.1f" % damage_threshold_in_percentage)
	name_parts.append("Time: %.1fs" % time_span)
	return " ➜ ".join(name_parts)


func _enter() -> void:
	# Reset tracking variables for a new entry.
	_damage_taken_since_start = 0.0
	_is_initialized = false # Assume initialization will fail until proven otherwise.

	_last_health = agent.stats.current_health
	_threshold = agent.stats.max_health * (damage_threshold_in_percentage / 100)
	_is_initialized = true # Mark as successfully initialized.


# Called every tick while the action is active in the behavior tree.
func _tick(_delta: float) -> Status:
	# If initialization failed in _enter, immediately return FAILURE.
	if not _is_initialized:
		return FAILURE 

	# Check if the time limit has been exceeded.
	if elapsed_time >= time_span:
		if _damage_taken_since_start >= _threshold:
			return SUCCESS # Time's up, but damage threshold was met.
		else:
			print_rich("[color=orange]Time span elapsed. Damage threshold not met (Current: %.1f / Required: %.1f)[/color]." % [_damage_taken_since_start, _threshold])
			return FAILURE # Time's up, and damage threshold was NOT met.

	var current_health_value: float = agent.stats.current_health

	# Calculate damage taken in this specific tick.
	# Use max(0.0, ...) to ensure damage is non-negative (health can't increase for "damage taken").
	var damage_this_tick: float = max(0.0, _last_health - current_health_value)
	
	# Accumulate total damage.
	_damage_taken_since_start += damage_this_tick

	# Update last health for the next tick's calculation.
	_last_health = current_health_value

	# Check if the accumulated damage meets or exceeds the threshold.
	if _damage_taken_since_start >= _threshold:
		return SUCCESS # Damage threshold met!

	return RUNNING


func _exit() -> void:
	_last_health = 0.0
	_damage_taken_since_start = 0.0
	_is_initialized = false
