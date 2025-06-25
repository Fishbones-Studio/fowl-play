extends Focusable3D

const ANIM_NAME: StringName= &"Grind"
const FADE_IN_TIME: float = 0.25 # seconds
const FADE_OUT_TIME: float = 0.5 # seconds

var fade_tween: Tween = null
var is_animation_playing: bool = false

@onready var animation_player: AnimationPlayer = %SawAnimationPlayer
@onready var saw_sound_player: AudioStreamPlayer3D = $SawSoundPlayer


func _ready() -> void:
	super()
	saw_sound_player.stream.loop = true
	saw_sound_player.volume_db = -80 # Start muted
	animation_player.speed_scale = 0.0 # Start paused


func focus() -> void:
	super()
	# Stop any running tween
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	# Play audio and animation if not already playing
	saw_sound_player.play()
	if not is_animation_playing:
		animation_player.play(ANIM_NAME)
		is_animation_playing = true
	# Create tween for fade in
	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(saw_sound_player, "volume_db", 0, FADE_IN_TIME)
	fade_tween.tween_property(animation_player, "speed_scale", 1.0, FADE_IN_TIME)


func unfocus() -> void:
	super()
	# Stop any running tween
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	# Create tween for fade out
	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(saw_sound_player, "volume_db", -80, FADE_OUT_TIME)
	fade_tween.tween_property(animation_player, "speed_scale", 0.0, FADE_OUT_TIME)
	fade_tween.tween_callback(Callable(self, "_on_fade_out_complete"))


func _on_fade_out_complete() -> void:
	saw_sound_player.stop()
	# Don't stop the animation, just leave it paused at speed_scale = 0
