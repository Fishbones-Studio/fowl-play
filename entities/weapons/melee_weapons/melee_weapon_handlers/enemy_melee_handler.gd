extends Node

@export var attacking_area: Area3D
@export var melee_weapon: MeleeWeaponNode

var cooldown: float = 0.0
var to_be_deleted: bool = false


func _ready() -> void:
	if not melee_weapon or not is_instance_valid(melee_weapon):
		to_be_deleted = true
		queue_free()


func _physics_process(_delta: float) -> void:
	if to_be_deleted: return
	
	if cooldown > 0.0:
		cooldown -= _delta
	else:
		var targets: Array[Node3D] = attacking_area.get_overlapping_bodies()
		for target in targets:
			if target == GameManager.chicken_player and melee_weapon and melee_weapon.melee_state_machine and melee_weapon.melee_state_machine.current_state.state_type == WeaponEnums.WeaponState.IDLE:
				melee_weapon.melee_state_machine.melee_combat_transition_state.emit(WeaponEnums.WeaponState.WINDUP, {})
				cooldown = melee_weapon.current_weapon.current_weapon.cooldown_time
