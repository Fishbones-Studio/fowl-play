extends Node3D

var current_weapon_instance : Node3D
var WeaponState = WeaponEnums.WeaponState
var current_state = WeaponState.IDLE

@export var current_weapon: WeaponResource

var windup_timer
var attack_duration
var cooldown_timer

func _ready():
	if not current_weapon:
		print(current_weapon)
		push_error("no weapon")
		return

	equip_weapon(current_weapon)

	windup_timer = current_weapon.windup_time
	attack_duration = current_weapon.attack_duration
	cooldown_timer = current_weapon.cooldown_time

func _process(delta):
	match current_state:
		WeaponState.IDLE:
			pass

		WeaponState.WINDUP:
			windup_timer -= delta
			if windup_timer <= 0:
				current_state = WeaponState.ATTACKING
				current_weapon.attack()
				print("Attacking with", current_weapon.name)

		WeaponState.ATTACKING:
			attack_duration -= delta
			if attack_duration <= 0:
				current_state = WeaponState.COOLDOWN
				cooldown_timer = current_weapon.cooldown_time
				print("Cooldown for", current_weapon.name)

		WeaponState.COOLDOWN:
			cooldown_timer -= delta
			if cooldown_timer <= 0:
				current_state = WeaponState.IDLE
				print("Ready to attack again!")

func equip_weapon(weapon_resource: WeaponResource):
	if current_weapon_instance:
		current_weapon_instance.queue_free()

	current_weapon = weapon_resource

	if weapon_resource.model:
		current_weapon_instance = weapon_resource.model.instantiate()
		add_child(current_weapon_instance) #Corrected line
	elif weapon_resource:
		current_weapon_instance = weapon_resource.instantiate()
		add_child(current_weapon_instance)

	print("Equipped:", current_weapon.name)
	current_state = WeaponState.IDLE
