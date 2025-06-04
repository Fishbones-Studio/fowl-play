class_name RangedWindupState
extends BaseRangedCombatState

@export var windup_sound: AudioStreamPlayer3D

var _windup_timer: float = 0.0


func _init()-> void:
	state_type = WeaponEnums.WeaponState.WINDUP
	if animation_name.is_empty():
		animation_name = "Windup"


func enter(_previous_state, _info: Dictionary = {}) -> void:
	_windup_timer = 0.0

	if windup_sound:
		windup_sound.play()


func process(delta: float) -> void:
	_windup_timer += delta

	if _windup_timer >= weapon.current_weapon.windup_time:
		transition_signal.emit(WeaponEnums.WeaponState.ATTACKING, {})


func exit() -> void:
	if windup_sound and windup_sound.playing and weapon.current_weapon.allow_early_release:
		windup_sound.stop()
