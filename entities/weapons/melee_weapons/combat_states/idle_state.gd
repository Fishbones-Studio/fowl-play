## IdleState: The weapon is idle and waiting for input.
extends BaseCombatState

## The minimum time (in seconds) to wait before potentially playing the idle animation.
@export var min_idle_interval: float = 3.0
## The maximum time (in seconds) to wait before potentially playing the idle animation.
@export var max_idle_interval: float = 7.0

var time_until_next_idle: float = 0.0


func _init() -> void:
	state_type = WeaponEnums.WeaponState.IDLE


func enter(_previous_state, _information: Dictionary = {}) -> void:
	_reset_idle_timer()


# In the process, randomly play the idle animation if it exists
func process(delta: float) -> void:
	# Ensure we have an animation player and the specified idle animation
	if (
		weapon_node.animation_player
		and weapon_node.animation_player.has_animation(ANIMATION_NAME)
	):
		# Only countdown and play if no other animation is currently running
		if not weapon_node.animation_player.is_playing():
			if time_until_next_idle > 0:
				time_until_next_idle -= delta
			else:
				# Time's up, play the idle animation
				weapon_node.animation_player.play(ANIMATION_NAME)
				weapon_node.animation_player.queue("RESET")
				# Reset the timer for the next random interval
				_reset_idle_timer()


## Resets the idle timer to a new random value within the defined range.
func _reset_idle_timer() -> void:
	if max_idle_interval > min_idle_interval:
		time_until_next_idle = randf_range(min_idle_interval, max_idle_interval)
	else:
		# Fallback to min_interval if max is not greater than min
		time_until_next_idle = min_idle_interval
		
	# Take the current animation length into account
	if weapon_node.animation_player && weapon_node.animation_player.is_playing():
		time_until_next_idle += weapon_node.animation_player.get_current_animation_length()
