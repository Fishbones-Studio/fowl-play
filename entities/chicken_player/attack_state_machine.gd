extends Node


var current_attack_state = WeaponEnums.WeaponStates.IDLE


var windup_timer: float = 0.0
var attack_timer: float = 0.0
var cooldown_timer: float = 0.0


@export var weapon_state_machine: WeaponStateMachine

func attack():
	if current_attack_state == WeaponEnums.WeaponStates.IDLE:
		var current_weapon = weapon_state_machine.get_current_weapon_stats()
		if current_weapon:
			current_attack_state = WeaponEnums.WeaponStates.WINDUP
			windup_timer = current_weapon.windup_time
			print("Starting windup for", current_weapon.name)

func _process(delta):
	match current_attack_state:
		WeaponEnums.WeaponStates.IDLE:
			pass  

		WeaponEnums.WeaponStates.WINDUP:
			windup_timer -= delta
			if windup_timer <= 0:
				current_attack_state = WeaponEnums.WeaponStates.ATTACKING
				var current_weapon = weapon_state_machine.get_current_weapon_stats()
				attack_timer = current_weapon.attack_duration
				current_weapon.attack() 
				print("Attacking with", current_weapon.name)

		WeaponEnums.WeaponStates.ATTACKING:
			attack_timer -= delta
			if attack_timer <= 0:
				current_attack_state = WeaponEnums.WeaponStates.COOLDOWN
				var current_weapon = weapon_state_machine.get_current_weapon_stats()
				cooldown_timer = current_weapon.cooldown_time
				print("Cooldown for", current_weapon.name)

		WeaponEnums.WeaponStates.COOLDOWN:
			cooldown_timer -= delta
			if cooldown_timer <= 0:
				current_attack_state = WeaponEnums.WeaponStates.IDLE
				print("Ready to attack again!")
