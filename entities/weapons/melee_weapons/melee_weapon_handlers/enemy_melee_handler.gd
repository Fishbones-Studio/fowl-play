extends Node

@export var attacking_area : Area3D
@export var melee_weapon : MeleeWeaponNode

var cooldown : float = 0.0

func _physics_process(_delta: float) -> void:
	if cooldown > 0.0:
		cooldown -= _delta
	else:
		var targets: Array[Node3D] = attacking_area.get_overlapping_bodies()
		for target in targets:
			if target == GameManager.chicken_player && melee_weapon && melee_weapon.melee_state_machine:
				melee_weapon.melee_state_machine.melee_combat_transition_state.emit(WeaponEnums.WeaponState.WINDUP, {})
				cooldown = melee_weapon.current_weapon.current_weapon.cooldown_time
