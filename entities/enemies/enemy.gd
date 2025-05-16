class_name Enemy
extends CharacterBody3D

signal damage_taken

@export var stats: LivingEntityStats
@export var type: EnemyEnums.EnemyTypes
@export var enemy_model: Node3D
@export var knockback_decay: int = 50 # Rate at which the knockback decays per second
@export_dir var dialogue_path: String
@export var name_label_template_string: String ## String template, requires 1 %s which will be replaced with the name specified in the associated stats

var is_immobile: bool = false

var _knockback: Vector3 = Vector3.ZERO

@onready var health_bar: HealthBar = %EnemyHealthBar
@onready var enemy_name_label : Label = %EnemyNameLabel
@onready var movement_component: EnemyMovementComponent = $MovementComponent
@onready var enemy_weapon_controller: EnemyWeaponController = $EnemyWeaponController
@onready var enemy_ability_controller: EnemyAbilityController = $EnemyAbilityController
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var shape: CollisionShape3D = $CollisionShape3D
@onready var immobile_timer: Timer = $ImmobileTimer
@onready var on_hurt: AudioStreamPlayer = $OnHurtAudio


func _ready() -> void:
	stats.init()
	health_bar.init_health(stats.max_health, stats.current_health)
	enemy_name_label.text = name_label_template_string % stats.name.capitalize()

	collision_layer = 4
	GameManager.current_enemy = self
	SignalManager.weapon_hit_target.connect(_take_damage)


func _physics_process(delta: float) -> void:
	apply_gravity(delta)

	if is_immobile:
		velocity += _knockback
		_knockback = _knockback.move_toward(Vector3.ZERO, knockback_decay * delta)

	move_and_slide()


func _process(_delta: float) -> void:
	stats.regen_stamina(stats.stamina_regen)
	stats.regen_health(stats.health_regen)


func get_stats_resource() -> LivingEntityStats:
	if stats == null:
		push_warning("Attempted to get stats resource before it was assigned!")
	return stats


func _take_damage(target: PhysicsBody3D, damage: float, damage_type: DamageEnums.DamageTypes, info: Dictionary = {}) -> void:
	if target == self:
		if "knockback" in info:
			# Set knockback force
			_knockback = info["knockback"]

			if not velocity.is_equal_approx(Vector3.ZERO):
				_knockback *= 2

			# Set immobile time
			var immobile_time: float = _knockback.length() / knockback_decay
			if not is_equal_approx(immobile_time, 0):
				immobile_timer.wait_time = immobile_time
				immobile_timer.start()
				is_immobile = true

		# Play hurt sound
		on_hurt.play()

		damage_taken.emit(stats.drain_health(damage, damage_type))
		health_bar.set_health(stats.current_health)

		if stats.current_health <= 0:
			_die()



func _die() -> void:
	SignalManager.enemy_died.emit()
	print(name, " has died!")
	queue_free()


## Applies jump or fall gravity based on velocity
func apply_gravity(delta: float) -> void:
	velocity.y += movement_component.get_gravity(velocity) * delta


func _on_immobile_timer_timeout() -> void:
	is_immobile = false
