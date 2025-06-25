class_name BasePlayerMovementState
extends BaseState

@export_group("State Config")
@export var state_type: PlayerEnums.PlayerStates
@export_group("State Audio")
@export var state_audio_file: AudioStream
@export var state_audio_player: AudioStreamPlayer3D
@export var loop_audio: bool = false
@export var state_audio_db: float = 0.0 ## Additional decibel control for this state

var player: ChickenPlayer
var previous_state: BasePlayerMovementState
var movement_component: PlayerMovementComponent
var animation_tree: AnimationTree

## Called once when entering the state.
##
## Parameters:
## prev_state: The state that was active before this one.
func enter(prev_state: BasePlayerMovementState, _info: Dictionary = {}) -> void:
	previous_state = prev_state
	if state_audio_player and state_audio_file:
		# Set looping based on the variable
		if state_audio_file is AudioStreamWAV or AudioStreamMP3 or AudioStreamOggVorbis:
			state_audio_file.loop = loop_audio
		# Set decibel volume
		state_audio_player.volume_db = state_audio_db
		# Assign and play
		state_audio_player.stream = state_audio_file
		state_audio_player.play()
		
func exit() -> void:
	if state_audio_player && state_audio_player.stream:
		# If we're stopping the audio (looping case), restore volume before stopping
		if loop_audio:
			state_audio_player.stop()
			state_audio_player.volume_db = 0.0

		# Dont restore volume if it is still playing
		# If still playing, the next state will handle the volume appropriately
		if not state_audio_player.playing:
			state_audio_player.volume_db = 0.0
		
		

################################################################################
# The following are non spefic FSM-methods, i.e. utility methods
# that may be used by multiple states.
################################################################################

## Applies jump or fall gravity based on player velocity
func apply_gravity(delta: float) -> void:
	player.velocity.y += movement_component.get_gravity(player.velocity) * delta

func apply_movement(velocity: Vector3) -> void:
	player.velocity.x = velocity.x
	player.velocity.z = velocity.z
	player.move_and_slide()

func is_sprinting() -> bool:
	return Input.is_action_pressed("sprint") and player.stats.current_stamina >= movement_component.sprint_stamina_threshold

func get_gravity(velocity: Vector3) -> float:
	return movement_component.get_gravity(velocity)

func get_jump_velocity() -> float:
	return movement_component.get_jump_velocity()

func get_player_input_dir() -> Vector2:
	return movement_component.get_player_input_dir()

func get_player_direction() -> Vector3:
	return movement_component.get_player_direction()
