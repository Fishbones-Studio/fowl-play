class_name CooldownIdleState extends BaseRangedCombatState

var _cooldown_timer: float = 0.0

func _init()-> void:
	state_type = WeaponEnums.WeaponState.COOLDOWN
	if ANIMATION_NAME.is_empty():
		ANIMATION_NAME = "Cooldown"

func enter(_previous_state, _info: Dictionary = {}) -> void:
	if weapon.entity_stats.is_player:
		SignalManager.cooldown_item_slot.emit(weapon.current_weapon, weapon.current_weapon.cooldown_time, true)
	_cooldown_timer = 0.0


func physics_process(delta: float) -> void:
	_cooldown_timer += delta
	if _cooldown_timer >= weapon.current_weapon.cooldown_time:
		transition_signal.emit(WeaponEnums.WeaponState.IDLE, {})
