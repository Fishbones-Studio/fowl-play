extends Node3D

var current_weapon_instance : Node3D
var WeaponState = WeaponEnums.WeaponState
var current_state = WeaponState.IDLE

@export var current_weapon: WeaponResource

var windup_timer
var attack_duration
var cooldown_timer

@onready var HitBox: Area3D = $"../HitArea"

func _ready():
	if not current_weapon:
		print(current_weapon)
		push_error("no weapon")
		return

	equip_weapon(current_weapon)

	HitBox.area_entered.connect(on_area_entered) # Connect the signal

func _process(delta):
	match current_state:
		WeaponState.IDLE:
			if Input.is_action_just_pressed("attack"): # Check for mouse click
				current_state = WeaponState.WINDUP
				windup_timer = current_weapon.windup_time #reset timer
				

		WeaponState.WINDUP:
			windup_timer -= delta
			if windup_timer <= 0:
				current_state = WeaponState.ATTACKING
				current_weapon.attack()
				attack_duration = current_weapon.attack_duration #reset timer
				

		WeaponState.ATTACKING:
			attack_duration -= delta
			if attack_duration <= 0:
				current_state = WeaponState.COOLDOWN
				cooldown_timer = current_weapon.cooldown_time #reset timer
				

		WeaponState.COOLDOWN:
			cooldown_timer -= delta
			if cooldown_timer <= 0:
				current_state = WeaponState.IDLE
				

func equip_weapon(weapon_resource: WeaponResource):
	if current_weapon_instance:
		current_weapon_instance.queue_free()

	current_weapon = weapon_resource

	if weapon_resource.model:
		current_weapon_instance = weapon_resource.model.instantiate()
		add_child(current_weapon_instance)
	elif weapon_resource:
		current_weapon_instance = weapon_resource.instantiate()
		add_child(current_weapon_instance)

	
	current_state = WeaponState.IDLE

func on_area_entered(area):
	if area.is_in_group(area.get_parent()):
		print("enemy found")
		if current_weapon:
			if current_weapon.damage:
				
				area.get_parent().take_damage(current_weapon.damage)
			else:
				print("Weapon damage is not set")
		else:
			print("Current weapon is not set")
