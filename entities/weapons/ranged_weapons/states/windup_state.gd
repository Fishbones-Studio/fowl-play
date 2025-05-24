extends BaseRangedCombatState

@export var windup_sound: AudioStreamPlayer

var _windup_timer: float = 0.0


func _init()-> void:
	state_type = WeaponEnums.WeaponState.WINDUP
	if ANIMATION_NAME.is_empty():
		ANIMATION_NAME = "Windup"


func enter(_previous_state, _info: Dictionary = {}) -> void:
	_windup_timer = 0.0
	windup_sound.play()


func process(delta: float) -> void:
	_windup_timer += delta
	
	if _windup_timer >= weapon.current_weapon.windup_time:
		transition_signal.emit(WeaponEnums.WeaponState.ATTACKING, {})
